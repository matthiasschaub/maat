from time import sleep
from uuid import uuid4

import pytest
import requests
from schema import Schema


@pytest.fixture
def list_schema():
    """Response schema"""
    return Schema(
        {
            "lid": str,
            "title": str,
            "host": str,
            "public": bool,
        },
    )


@pytest.fixture
def lists_schema(list_schema):
    """Response schema"""
    return Schema([list_schema])


@pytest.mark.parametrize("payload", (None, "", " ", {}, []))
def test_lists_put_empty_payload(payload, zod):
    url = "/apps/maat/api/lists"
    response = zod.put(url, json=payload)
    assert response.status_code in (418, 500)


@pytest.mark.parametrize("title", (None, "", " "))
def test_lists_put_invalid_title(title, zod):
    list_ = {
        "lid": str(uuid4()),
        "title": title,
        "public": False,
    }
    url = "/apps/maat/api/lists"

    # PUT /lists
    response = zod.put(url, json=list_)
    assert response.status_code in (422, 500)

    # GET /lists
    response = zod.get(url)
    assert response.status_code == 200
    result = response.json()
    assert list_ not in result


def test_lists_get_all(zod, list_, lists_schema):
    # GET /lists
    url = "/apps/maat/api/lists"
    response = zod.get(url)
    assert response.status_code == 200
    result = response.json()
    assert lists_schema.is_valid(result)
    assert list_ in result


@pytest.mark.usefixtures("list_")
def test_lists_get_all_unauthorized():
    # GET /lists
    url = "http://localhost:8080/apps/maat/api/lists"
    response = requests.get(url)
    assert response.status_code == 401


def test_lists_get_single(zod, gid, list_, list_schema):
    # GET /lists/{uuid}
    url = f"/apps/maat/api/lists/{gid}"
    response = zod.get(url)
    assert response.status_code == 200
    result = response.json()
    assert list_schema.is_valid(result)
    assert result == list_


def test_lists_get_single_not_found(zod):
    # GET /lists/{uuid}
    url = f"/apps/maat/api/lists/{str(uuid4())}"
    response = zod.get(url)
    # TODO: should be 4xx
    assert response.status_code == 500


def test_lists_delete(zod, gid, list_):
    # PUT
    url = f"/apps/maat/api/lists/{gid}"
    response = zod.delete(url)
    assert response.status_code == 200

    # GET /lists
    url = "/apps/maat/api/lists"
    response = zod.get(url)
    assert response.status_code == 200
    result = response.json()
    assert list_ not in result


# @pytest.mark.usefixtures("member")
# def test_lists_delete_unauthorized(zod, nus, gid, list):
#     # wait for join
#     sleep(0.5)

#     # PUT
#     url = f"/apps/maat/api/lists/{gid}"
#     response = nus.delete(url)
#     assert response.status_code == 403

#     # GET /lists
#     url = "/apps/maat/api/lists"
#     response = zod.get(url)
#     assert response.status_code == 200
#     result = response.json()
#     assert list in result


# @pytest.mark.usefixtures("list")
# def test_lists_get_private(gid):
#     # GET /lists/{uuid}
#     url = f"http://localhost:8080/apps/maat/api/lists/{gid}"
#     response = requests.get(url)
#     assert response.status_code == 401


# def test_lists_get_public(gid, list_public, list_schema):
#     # GET /lists/{uuid}
#     url = f"http://localhost:8080/apps/maat/api/lists/{gid}"
#     response = requests.get(url)
#     assert response.status_code == 200
#     result = response.json()
#     assert list_schema.is_valid(result)
#     assert result == list_public


# @pytest.mark.usefixtures("list")
# def test_lists_delete_private(gid):
#     # PUT
#     url = f"http://localhost:8080/apps/maat/api/lists/{gid}"
#     response = requests.delete(url)
#     assert response.status_code == 401


# @pytest.mark.usefixtures("list_public")
# def test_lists_delete_public(gid):
#     # PUT
#     url = f"http://localhost:8080/apps/maat/api/lists/{gid}"
#     response = requests.delete(url)
#     assert response.status_code == 401
