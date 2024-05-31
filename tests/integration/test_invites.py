import pytest
import requests


@pytest.mark.parametrize(
    "json",
    (
        {},
        "",
        "~zod",
        {"invitee": ""},
        {"invitee": None},
        {"invitee": " "},
    ),
)
@pytest.mark.usefixtures("list_")
def test_put_invitee_invaLid(json, zod, gid):
    url = f"/apps/maat/api/lists/{gid}/invitees"
    resp = zod.put(url, json=json)
    assert resp.status_code == 422


@pytest.mark.usefixtures("list_")
def test_put_invitee_empty_body(zod, gid):
    url = f"/apps/maat/api/lists/{gid}/invitees"
    resp = zod.put(url, json=None)
    assert resp.status_code == 422


@pytest.mark.usefixtures("list_", "nus")
def test_put_invitees(zod, gid):
    url = f"/apps/maat/api/lists/{gid}/invitees"
    response = zod.put(url, json={"invitee": "~nus"})
    assert response.status_code == 200


def test_put_invitees_public(gid):
    """Test PUT /invitees with unauthorized requests."""
    url = f"http://localhost:8080/apps/maat/api/lists/{gid}/invitees"
    response = requests.put(url, json={"invitee": "~nus"})
    assert response.status_code == 500


def test_get_invites(nus, gid, list_, invitee_nus):
    # GET /invites (nus)
    url = "/apps/maat/api/invites"
    response = nus.get(url)
    assert response.status_code == 200
    result = response.json()
    assert isinstance(result, list)
    assert list_ in result
