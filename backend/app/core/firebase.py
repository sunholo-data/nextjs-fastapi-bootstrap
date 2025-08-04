import logging
import os
from datetime import datetime
from typing import Any, Dict, Optional

import firebase_admin
from firebase_admin import credentials, firestore

logger = logging.getLogger(__name__)

# Global Firebase app instance
_firebase_app: Optional[firebase_admin.App] = None
_firestore_client: Optional[firestore.Client] = None


def get_firebase_app() -> firebase_admin.App:
    """Get or initialize Firebase app."""
    global _firebase_app

    if _firebase_app is None:
        logger.info("Initializing Firebase app...")

        project_id = os.getenv("FIREBASE_PROJECT_ID")
        if not project_id:
            raise ValueError("FIREBASE_PROJECT_ID environment variable is required")

        try:
            logger.info("Using Application Default Credentials for Firebase")
            # Always use Application Default Credentials (works on Cloud Run and local with gcloud)
            cred = credentials.ApplicationDefault()
            config = {"projectId": project_id}

            _firebase_app = firebase_admin.initialize_app(cred, config)

            logger.info(
                f"Firebase app initialized successfully for project: {project_id}"
            )

        except Exception as e:
            logger.error(f"Failed to initialize Firebase app: {str(e)}")
            raise

    return _firebase_app


def get_firestore_client() -> firestore.Client:
    """Get or initialize Firestore client."""
    global _firestore_client

    if _firestore_client is None:
        logger.info("Initializing Firestore client...")

        try:
            # Ensure Firebase app is initialized
            get_firebase_app()

            # Get the database ID from environment or use '(default)' as default
            database_id = os.getenv("FIRESTORE_DATABASE_ID", "(default)")
            logger.info(f"Using Firestore database: {database_id}")

            # Create Firestore client with the specific database
            # Note: database_id parameter is supported starting from firebase-admin 6.6.0
            _firestore_client = firestore.client(database_id=database_id)

            # Test the connection by attempting to read from a collection
            logger.debug("Testing Firestore connection...")
            test_collection = _firestore_client.collection("_connection_test")
            # This will fail if we don't have proper permissions, which is expected
            try:
                list(test_collection.limit(1).get())
                logger.info("Firestore connection test successful")
            except Exception as test_e:
                # Connection test may fail due to permissions, but client creation succeeded
                logger.debug(
                    f"Firestore connection test failed (this may be normal): {str(test_e)}"
                )

            logger.info("Firestore client initialized successfully")

        except Exception as e:
            logger.error(f"Failed to initialize Firestore client: {str(e)}")
            raise

    return _firestore_client


def test_firestore_connection() -> Dict[str, Any]:
    """Test Firestore connection and return status."""
    try:
        client = get_firestore_client()

        # Try to write and read a test document
        test_collection = client.collection("_health_check")
        test_doc = {"timestamp": datetime.utcnow(), "test": True}

        # Add test document
        doc_ref = test_collection.add(test_doc)[1]

        # Read it back
        retrieved_doc = doc_ref.get()

        # Clean up
        doc_ref.delete()

        return {
            "status": "healthy",
            "message": "Firestore connection successful",
            "can_read": True,
            "can_write": True,
            "document_id": doc_ref.id,
        }

    except Exception as e:
        logger.error(f"Firestore connection test failed: {str(e)}")
        return {
            "status": "error",
            "message": f"Firestore connection failed: {str(e)}",
            "can_read": False,
            "can_write": False,
            "error": str(e),
        }
