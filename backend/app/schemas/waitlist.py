from datetime import datetime

from pydantic import BaseModel, EmailStr


class WaitlistEntry(BaseModel):
    email: EmailStr


class WaitlistResponse(BaseModel):
    message: str
    email: str
    timestamp: datetime
