import os

import firebase_admin
import pytest

import app.core.firebase


@pytest.fixture(autouse=True)
def setup_test_environment(monkeypatch):
    """Automatically set up test environment for all tests."""
    # Ensure we're using the test project
    monkeypatch.setenv("FIREBASE_PROJECT_ID", "multivac-internal-dev")
    # Use test database if specified, otherwise fall back to main database
    if not os.getenv("FIRESTORE_DATABASE_ID"):
        monkeypatch.setenv("FIRESTORE_DATABASE_ID", "tagassistant")

    # Reset Firebase singleton before each test
    app.core.firebase._firebase_app = None
    app.core.firebase._firestore_client = None

    # Delete all Firebase apps to avoid "app already exists" errors
    try:
        for app_name in list(firebase_admin._apps.keys()):
            firebase_admin.delete_app(firebase_admin._apps[app_name])
    except Exception:
        pass  # Ignore errors if no apps exist

    yield

    # Reset Firebase singleton after each test
    app.core.firebase._firebase_app = None
    app.core.firebase._firestore_client = None

    # Clean up Firebase apps after each test
    try:
        for app_name in list(firebase_admin._apps.keys()):
            firebase_admin.delete_app(firebase_admin._apps[app_name])
    except Exception:
        pass  # Ignore errors if no apps to delete


@pytest.fixture
def cleanup_test_emails():
    """Fixture to clean up test emails after tests."""
    from app.core.firebase import get_firestore_client

    test_emails = []

    yield test_emails

    # Clean up any test emails that were created
    if test_emails:
        try:
            db = get_firestore_client()
            waitlist_collection = db.collection("waitlist")

            for email in test_emails:
                # Find and delete documents with test emails
                docs = waitlist_collection.where("email", "==", email).get()
                for doc in docs:
                    doc.reference.delete()
        except Exception as e:
            # Don't fail tests if cleanup fails
            print(f"Warning: Failed to clean up test data: {e}")
