from uuid import uuid4
from time import sleep

import pytest
import requests
from schema import Schema


@pytest.fixture
def list_schema():
    """Response schema"""
    return Schema(
        {
            "gid": str,
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
    assert response.status_code in (422, 500)


@pytest.mark.parametrize("title", (None, "", " "))
def test_lists_put_invalid_title(title, zod):
    list_ = {
        "gid": str(uuid4()),
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


def test_lists_put(zod, uuid):
    list_ = {
        "gid": uuid,
        "title": "assembly",
        "public": False,
    }
    url = "/apps/maat/api/lists"
    response = zod.put(url, json=list_)
    assert response.status_code == 200


def test_lists_put_unauthorized(zod, uuid):
    list_ = {
        "gid": uuid,
        "title": "assembly",
        "public": False,
    }
    url = "http://localhost:8080/apps/maat/api/lists"
    response = requests.put(url, json=list_)
    assert response.status_code == 401


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


def test_lists_all_ordered(zod, list_):
    url = "/apps/maat/api/lists"
    list_2 = {
        "gid": str(uuid4()),
        "title": "aaa",
        "public": False,
    }
    zod.put(url, json=list_2)
    list_3 = {
        "gid": str(uuid4()),
        "title": "bbb",
        "public": False,
    }
    zod.put(url, json=list_3)
    response = zod.get(url)
    result = [r["gid"] for r in response.json()]
    assert (
        result.index(list_2["gid"])
        < result.index(list_["gid"])
        < result.index(list_3["gid"])
    )


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


@pytest.mark.usefixtures("list_")
def test_lists_update(zod, gid, list_):
    """Put with existing ID."""
    list_2 = {
        "gid": gid,
        "title": "assembly2",
        "host": "~zod",
        "public": False,
    }
    assert list_ != list_2

    url = f"/apps/maat/api/lists/{gid}"
    response = zod.get(url)
    result = response.json()
    assert result == list_

    url = "/apps/maat/api/lists"
    zod.put(url, json=list_2)
    url = f"/apps/maat/api/lists/{gid}"
    response = zod.get(url)
    result = response.json()
    assert result == list_2


@pytest.mark.usefixtures("list_")
def test_lists_get_private(gid):
    # GET /lists/{uuid}
    url = f"http://localhost:8080/apps/maat/api/lists/{gid}"
    response = requests.get(url)
    assert response.status_code == 401


def test_lists_get_public(gid, list_public, list_schema):
    # GET /lists/{uuid}
    url = f"http://localhost:8080/apps/maat/api/lists/{gid}"
    response = requests.get(url)
    assert response.status_code == 200
    result = response.json()
    assert list_schema.is_valid(result)
    assert result == list_public


@pytest.mark.usefixtures("list_")
def test_lists_delete_private(gid):
    # PUT
    url = f"http://localhost:8080/apps/maat/api/lists/{gid}"
    response = requests.delete(url)
    assert response.status_code == 401


@pytest.mark.usefixtures("list_public")
def test_lists_delete_public(gid):
    # PUT
    url = f"http://localhost:8080/apps/maat/api/lists/{gid}"
    response = requests.delete(url)
    assert response.status_code == 401
