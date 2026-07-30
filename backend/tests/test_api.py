import os

os.environ["DATABASE_URL"] = "sqlite://"
os.environ["DEV_AUTH"] = "true"
os.environ["DEV_OTP"] = "1234"
os.environ["SEED_DEMO_DATA"] = "true"
os.environ["JWT_SECRET_KEY"] = "test-secret"

from fastapi.testclient import TestClient

from app.main import app


def login(client: TestClient, mobile: str) -> dict[str, str]:
    requested = client.post("/api/v1/auth/request-otp", json={"mobile": mobile})
    assert requested.status_code == 200
    verified = client.post(
        "/api/v1/auth/verify-otp",
        json={"mobile": mobile, "otp": "1234"},
    )
    assert verified.status_code == 200, verified.text
    return {"Authorization": f"Bearer {verified.json()['access_token']}"}


def test_health_and_authentication() -> None:
    with TestClient(app) as client:
        health = client.get("/health")
        assert health.status_code == 200
        assert health.json()["status"] == "ok"

        headers = login(client, "9876543210")
        current = client.get("/api/v1/auth/me", headers=headers)
        assert current.status_code == 200
        assert current.json()["mobile"] == "9876543210"


def test_parent_learning_endpoints_and_dashboard() -> None:
    with TestClient(app) as client:
        headers = login(client, "9876543210")
        children = client.get("/api/v1/children", headers=headers)
        assert children.status_code == 200
        child_id = children.json()[0]["id"]

        dashboard = client.get(
            f"/api/v1/dashboard?child_id={child_id}",
            headers=headers,
        )
        assert dashboard.status_code == 200
        assert dashboard.json()["selected_child"]["id"] == child_id
        assert dashboard.json()["courses"]
        assert dashboard.json()["worksheets"]

        created = client.post(
            "/api/v1/children",
            headers=headers,
            json={
                "name": "Test Student",
                "age": 7,
                "class_name": "Class 2",
                "school_name": "Optional School",
            },
        )
        assert created.status_code == 201
        assert created.json()["school_name"] == "Optional School"


def test_practice_session_is_persisted_and_answers_are_validated() -> None:
    with TestClient(app) as client:
        headers = login(client, "9876543210")
        child_id = client.get("/api/v1/children", headers=headers).json()[0]["id"]
        activity = client.get(
            f"/api/v1/practice/daily?child_id={child_id}",
            headers=headers,
        ).json()

        started = client.post(
            "/api/v1/practice/sessions",
            headers=headers,
            json={"child_id": child_id, "activity_id": activity["id"]},
        )
        assert started.status_code == 201
        session = started.json()
        question = session["activity"]["questions"][0]

        answered = client.post(
            f"/api/v1/practice/sessions/{session['id']}/answers",
            headers=headers,
            json={
                "question_id": question["id"],
                "answer": question["operand_a"] + question["operand_b"],
                "elapsed_seconds": 5,
            },
        )
        assert answered.status_code == 200
        assert answered.json()["is_correct"] is True

        duplicate = client.post(
            f"/api/v1/practice/sessions/{session['id']}/answers",
            headers=headers,
            json={"question_id": question["id"], "answer": 0},
        )
        assert duplicate.status_code == 409

        completed = client.post(
            f"/api/v1/practice/sessions/{session['id']}/complete",
            headers=headers,
        )
        assert completed.status_code == 200
        assert completed.json()["result"]["score"] == 1


def test_child_data_is_private_to_the_parent() -> None:
    with TestClient(app) as client:
        owner_headers = login(client, "9876543210")
        child_id = client.get("/api/v1/children", headers=owner_headers).json()[0]["id"]
        other_headers = login(client, "9123456789")

        response = client.get(
            f"/api/v1/children/{child_id}",
            headers=other_headers,
        )
        assert response.status_code == 404


def test_admin_endpoints_require_admin_role() -> None:
    with TestClient(app) as client:
        parent_headers = login(client, "9876543210")
        denied = client.post(
            "/api/v1/admin/courses",
            headers=parent_headers,
            json={"title": "Should not be created"},
        )
        assert denied.status_code == 403

        admin_headers = login(client, "9999999999")
        created = client.post(
            "/api/v1/admin/courses",
            headers=admin_headers,
            json={"title": "Admin-created course"},
        )
        assert created.status_code == 201

        overview = client.get("/api/v1/admin/overview", headers=admin_headers)
        assert overview.status_code == 200
        assert overview.json()["active_students"] >= 3
