from typing import Optional

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    app_name: str = "App"
    debug: bool = True
    port: int = 8000

    # Firebase
    firebase_project_id: Optional[str] = None

    # Google API (not currently used)
    google_client_id: Optional[str] = None
    google_client_secret: Optional[str] = None
    google_redirect_uri: str = "http://localhost:8000/auth/callback"

    # Security (not currently used)
    secret_key: Optional[str] = None
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30

    # CORS
    frontend_url: str = "http://localhost:3000"

    # Monitoring (not currently used)
    monitoring_enabled: bool = True
    alert_webhook_url: Optional[str] = None

    # Mailgun (not currently used)
    mailgun_api_key: Optional[str] = None
    mailgun_domain: Optional[str] = None
    mailgun_from_email: str = "noreply@example.com"

    class Config:
        env_file = ".env"


settings = Settings()
