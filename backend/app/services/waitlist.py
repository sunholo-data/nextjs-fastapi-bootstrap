import logging
from datetime import datetime
from typing import Any, Dict, Optional

from google.api_core import exceptions as gcp_exceptions
from google.cloud.firestore_v1 import DocumentReference

from app.core.firebase import get_firestore_client

logger = logging.getLogger(__name__)


class WaitlistService:
    """Service for managing waitlist entries in Firestore."""

    COLLECTION_NAME = "waitlist"

    def __init__(self):
        try:
            self.db = get_firestore_client()
            self.collection = self.db.collection(self.COLLECTION_NAME)
            logger.info(
                f"WaitlistService initialized with collection: {self.COLLECTION_NAME}"
            )
        except Exception as e:
            logger.error(f"Failed to initialize WaitlistService: {str(e)}")
            raise

    def add_email(self, email: str) -> Dict[str, Any]:
        """
        Add an email to the waitlist.

        Args:
            email: The email address to add

        Returns:
            Dict containing the created entry data

        Raises:
            ValueError: If email already exists
            Exception: For Firestore connection or other errors
        """
        # Normalize email
        email = email.lower().strip()
        logger.info(f"Attempting to add email to waitlist: {email}")

        try:
            # Check if email already exists
            logger.debug(f"Checking if email {email} already exists")
            existing = self.collection.where("email", "==", email).limit(1).get()
            existing_list = list(existing)

            if len(existing_list) > 0:
                logger.warning(f"Email {email} already exists in waitlist")
                raise ValueError("Email already registered")

            # Create new entry
            timestamp = datetime.utcnow()
            entry_data = {
                "email": email,
                "created_at": timestamp,
                "source": "landing_page",
                "notified": False,
                "ip_address": None,  # Can be added later from request
                "user_agent": None,  # Can be added later from request
            }

            # Add to Firestore
            logger.debug(f"Adding new entry to Firestore: {entry_data}")
            doc_time, doc_ref = self.collection.add(entry_data)

            logger.info(
                f"Successfully added email {email} to waitlist with document ID: {doc_ref.id}"
            )

            return {"id": doc_ref.id, **entry_data}

        except ValueError:
            # Re-raise ValueError (email already exists)
            raise
        except gcp_exceptions.PermissionDenied as e:
            logger.error(f"Permission denied accessing Firestore: {str(e)}")
            raise Exception("Database permission error. Check Firebase authentication.")
        except gcp_exceptions.GoogleAPIError as e:
            logger.error(f"Google API error: {str(e)}")
            raise Exception(f"Database connection error: {str(e)}")
        except Exception as e:
            logger.error(f"Unexpected error adding email {email}: {str(e)}")
            raise Exception(f"Failed to add email to waitlist: {str(e)}")

    def get_email(self, email: str) -> Optional[Dict[str, Any]]:
        """Get a waitlist entry by email."""
        email = email.lower().strip()
        docs = self.collection.where("email", "==", email).limit(1).get()

        for doc in docs:
            return {"id": doc.id, **doc.to_dict()}

        return None

    def get_all_emails(self, limit: int = 100, offset: int = 0) -> list[Dict[str, Any]]:
        """Get all waitlist entries with pagination."""
        query = self.collection.order_by("created_at", direction="DESCENDING")

        if offset > 0:
            query = query.offset(offset)

        if limit > 0:
            query = query.limit(limit)

        docs = query.get()
        return [{"id": doc.id, **doc.to_dict()} for doc in docs]

    def get_count(self) -> int:
        """Get total count of waitlist entries."""
        # Note: This is not efficient for large collections
        # Consider using a counter document for production
        return len(list(self.collection.get()))
