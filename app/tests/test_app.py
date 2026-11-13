import pytest

from app import app


@pytest.fixture
def client():
    app.config.update(TESTING=True)
    return app.test_client()


def test_health_returns_ok(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.get_json() == {"status": "ok"}


def test_hello_greets_by_name(client):
    response = client.get("/hello/Gibson")
    assert response.status_code == 200
    assert response.get_json() == {"message": "Hello, Gibson!"}


def test_unknown_route_is_404(client):
    assert client.get("/nope").status_code == 404

def test_version_returns_version(client):
    response = client.get("/version")
    assert response.status_code == 200
    assert response.get_json() == {"version": "1.0.0"}
