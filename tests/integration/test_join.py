from time import sleep

import requests
import pytest


def test_post_join_public(gid, list_public):
    """Unauthenticated requests are blocked."""
    join = {
        "host": list_public["host"],
        "gid": gid,
    }
    url = "http://localhost:8080/apps/maat/api/join"
    response = requests.post(url, json=join)
    assert response.status_code == 401


def test_post_join_not_allowed(zod, nus, gid, list_):
    join = {
        "host": list_["host"],
        "gid": gid,
    }
    url = "/apps/maat/api/join"
    response = nus.post(url, json=join)
    # TODO: Should be 4xx
    assert response.status_code == 200

    # Await join
    # sleep(0.5)

    # GET /members (zod)
    url = f"/apps/maat/api/lists/{gid}/members"
    response = zod.get(url)
    assert response.status_code == 200
    result = response.json()
    assert "~nus" not in result


@pytest.mark.usefixtures("invitee_nus")
def test_post_join(nus, gid, list_):
    join = {
        "host": list_["host"],
        "gid": gid,
    }
    url = "/apps/maat/api/join"
    response = nus.post(url, json=join)
    assert response.status_code == 200


def test_join(zod, nus, gid, list_, member_nus):
    # GET /members (zod)
    url = f"/apps/maat/api/lists/{gid}/members"
    response = zod.get(url)
    assert response.status_code == 200
    result = response.json()
    assert result == [member_nus]

    # GET /lists (nus)
    url = f"/apps/maat/api/lists/{gid}"
    response = nus.get(url)
    assert response.status_code == 200
    result = response.json()
    assert result == list_

    # GET /members (nus)
    url = f"/apps/maat/api/lists/{gid}/members"
    response = nus.get(url)
    assert response.status_code == 200
    result = response.json()
    assert result == [member_nus]

    # GET /invites (nus)
    url = "/apps/maat/api/invites"
    response = nus.get(url)
    assert response.status_code == 200
    result = response.json()
    assert isinstance(result, list)
    assert {"host": list_["host"], "gid": gid} not in result
