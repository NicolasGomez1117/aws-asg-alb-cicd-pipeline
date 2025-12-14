from main import create_app


def test_index_route():
    app = create_app()
    client = app.test_client()
    resp = client.get("/")

    assert resp.status_code == 200
    payload = resp.get_json()
    assert payload["status"] == "ok"
