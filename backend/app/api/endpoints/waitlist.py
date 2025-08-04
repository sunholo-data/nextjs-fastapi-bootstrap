import logging
from datetime import datetime

from fastapi import APIRouter, HTTPException, Request

from app.schemas.waitlist import WaitlistEntry, WaitlistResponse
from app.services.waitlist import WaitlistService

router = APIRouter()
logger = logging.getLogger(__name__)


@router.post("/waitlist", response_model=WaitlistResponse)
async def join_waitlist(entry: WaitlistEntry, request: Request):
    """Add an email to the waiting list."""
    logger.info(f"🔔 Waitlist request received: {entry.email}")
    logger.info(
        f"📡 Request from: {request.client.host if request.client else 'unknown'}"
    )
    try:
        # Initialize service
        service = WaitlistService()

        # Add email to Firestore
        result = service.add_email(entry.email)

        # TODO: Send confirmation email via Mailgun

        logger.info(f"✅ Successfully added {entry.email} to waitlist")
        return WaitlistResponse(
            message="Successfully joined the waiting list!",
            email=result["email"],
            timestamp=result["created_at"],
        )

    except ValueError as e:
        # Email already exists
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Error adding email to waitlist: {str(e)}")
        raise HTTPException(
            status_code=500, detail="An error occurred. Please try again later."
        )


@router.get("/waitlist/count")
async def get_waitlist_count():
    """Get the total number of waitlist entries."""
    try:
        service = WaitlistService()
        count = service.get_count()
        return {"count": count}
    except Exception as e:
        logger.error(f"Error getting waitlist count: {str(e)}")
        raise HTTPException(status_code=500, detail="Error retrieving count")
