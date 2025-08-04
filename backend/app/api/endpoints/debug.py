import logging
import os

from fastapi import APIRouter, HTTPException

from app.core.firebase import test_firestore_connection
from app.services.waitlist import WaitlistService

router = APIRouter()
logger = logging.getLogger(__name__)


@router.get("/debug/firebase")
async def debug_firebase():
    """Debug endpoint to test Firebase/Firestore connectivity."""
    try:
        # Test basic connection
        connection_test = test_firestore_connection()

        # Get environment info
        env_info = {
            "USE_APPLICATION_DEFAULT_CREDENTIALS": os.getenv(
                "USE_APPLICATION_DEFAULT_CREDENTIALS"
            ),
            "FIREBASE_PROJECT_ID": os.getenv("FIREBASE_PROJECT_ID"),
            "FIREBASE_CREDENTIALS_SET": bool(os.getenv("FIREBASE_CREDENTIALS")),
        }

        return {"firebase_connection": connection_test, "environment": env_info}

    except Exception as e:
        logger.error(f"Debug Firebase test failed: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Debug test failed: {str(e)}")


@router.get("/debug/waitlist")
async def debug_waitlist():
    """Debug endpoint to test waitlist service."""
    try:
        service = WaitlistService()

        # Test basic service operations
        result = {
            "service_initialized": True,
            "collection_name": service.COLLECTION_NAME,
        }

        # Try to get count (this tests read access)
        try:
            count = service.get_count()
            result["current_count"] = count
            result["read_access"] = True
        except Exception as e:
            result["current_count"] = None
            result["read_access"] = False
            result["read_error"] = str(e)

        return result

    except Exception as e:
        logger.error(f"Debug waitlist test failed: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Waitlist debug failed: {str(e)}")


@router.post("/debug/test-email")
async def debug_test_email(test_email: str = "test@debug.local"):
    """Debug endpoint to test adding an email (for testing only)."""
    try:
        service = WaitlistService()

        # Try to add a test email
        result = service.add_email(test_email)

        return {
            "success": True,
            "message": "Test email added successfully",
            "result": result,
        }

    except ValueError as e:
        # Email already exists
        return {
            "success": False,
            "message": f"Test failed (expected): {str(e)}",
            "error_type": "duplicate_email",
        }
    except Exception as e:
        logger.error(f"Debug test email failed: {str(e)}")
        return {
            "success": False,
            "message": f"Test failed: {str(e)}",
            "error_type": "service_error",
        }
