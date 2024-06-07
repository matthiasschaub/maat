import pytest
import requests


@pytest.mark.usefixtures("list_")
def test_put_members(zod, gid):
    url = f"/apps/maat/api/list/{gid}/members"
    response = zod.put(url, json={})
    assert response.status_code == 404


@pytest.mark.usefixtures("list_")
def test_get_members(zod, nus, gid, member_nus):
    for ship in (zod, nus):
        url = f"/apps/maat/api/lists/{gid}/members"
        response = ship.get(url)
        assert response.status_code == 200
        result = response.json()
        assert isinstance(result, list)
        # TODO:
        # assert "~zod" in result
        assert member_nus in result


@pytest.mark.usefixtures("list_", "member_nus")
def test_get_members_unauthorized(gid):
    url = f"http://localhost:8080/apps/maat/api/lists/{gid}/members"
    response = requests.get(url)
    assert response.status_code == 401


@pytest.mark.usefixtures("list_public")
def test_get_members_public(gid):
    url = f"http://localhost:8080/apps/maat/api/lists/{gid}/members"
    response = requests.get(url)
    assert response.status_code == 401


@pytest.mark.usefixtures("list_")
def test_delete_members(zod, gid, member_nus):
    url = f"/apps/maat/api/lists/{gid}/members"
    response = zod.delete(url, json={"member": member_nus})
    assert response.status_code == 501


@pytest.mark.usefixtures("list_")
def test_delete_members_unauthorized(gid, member_nus):
    url = f"http://localhost:8080/apps/maat/api/lists/{gid}/members"
    response = requests.delete(url, json={"member": member_nus})
    assert response.status_code == 401


@pytest.mark.usefixtures("list_public")
def test_delete_members_public(zod, gid, member_nus):
    url = f"/apps/maat/api/lists/{gid}/members"
    response = zod.delete(url, json={"member": member_nus})
    # TODO: should be 200
    assert response.status_code == 501


@pytest.mark.usefixtures("list_public")
def test_delete_members_public_unauthorized(gid, member_nus):
    url = f"http://localhost:8080/apps/maat/api/list_s/{gid}/members"
    response = requests.delete(url, json={"member": member_nus})
    assert response.status_code == 501
