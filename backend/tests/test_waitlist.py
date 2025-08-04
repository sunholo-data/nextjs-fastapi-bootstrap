import uuid

from fastapi.testclient import TestClient

from main import app

client = TestClient(app)


def test_join_waitlist_success():
    """Test successfully joining the waitlist."""
    # Use a unique email for each test run
    unique_email = f"test-{uuid.uuid4().hex[:8]}@example.com"
    response = client.post("/api/waitlist", json={"email": unique_email})
    assert response.status_code == 200
    data = response.json()
    assert data["message"] == "Successfully joined the waiting list!"
    assert data["email"] == unique_email
    assert "timestamp" in data


def test_join_waitlist_duplicate():
    """Test joining waitlist with duplicate email."""
    # Use a unique email for this test
    email = f"duplicate-{uuid.uuid4().hex[:8]}@example.com"

    # First request should succeed
    response1 = client.post("/api/waitlist", json={"email": email})
    assert response1.status_code == 200

    # Second request with same email should fail
    response2 = client.post("/api/waitlist", json={"email": email})
    assert response2.status_code == 400
    assert "already registered" in response2.json()["detail"]


def test_join_waitlist_invalid_email():
    """Test joining waitlist with invalid email."""
    response = client.post("/api/waitlist", json={"email": "not-an-email"})
    assert response.status_code == 422
