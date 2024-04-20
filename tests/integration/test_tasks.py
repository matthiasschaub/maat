import pytest
from time import sleep
import requests
from schema import Schema
from uuid import uuid4


@pytest.fixture(scope="session")
def task_schema():
    """Response schema"""
    return Schema(
        {
            "gid": str,
            "tid": str,
            "title": str,
            "desc": str,
            "date": int,
            "done": bool,
            "tags": [str],
        },
    )


@pytest.fixture(scope="session")
def tasks_schema(task_schema):
    """Response schema"""
    return Schema([task_schema])


@pytest.mark.parametrize("title", ("", " "))
@pytest.mark.usefixtures("list_")
def test_task_put_invalid_title(zod, gid, title):
    task = {
        "gid": gid,
        "tid": str(uuid4()),
        "title": title,
        "desc": "blah",
        "date": 1699182124,
        "done": False,
        "tags": ["#areas"],
    }
    url = f"/apps/maat/api/lists/{gid}/tasks"
    # PUT /tasks
    response = zod.put(url, json=task)
    assert response.status_code == 422


@pytest.mark.parametrize("payload", ("", {}, None))
@pytest.mark.usefixtures("list_")
def test_task_put_empty_body(zod, gid, payload):
    url = f"/apps/maat/api/lists/{gid}/tasks"
    # PUT /tasks
    response = zod.put(url, json=payload)
    assert response.status_code in (500, 418)


@pytest.mark.usefixtures("list_")
def test_tasks_put(zod, gid):
    task = {
        "gid": gid,
        "tid": str(uuid4()),
        "title": "book a train ticket",
        "desc": "blah",
        "date": 1699182124,
        "done": False,
        "tags": ["#areas"],
    }

    url = f"/apps/maat/api/lists/{gid}/tasks"
    response = zod.put(url, json=task)
    assert response.status_code == 200


# @pytest.mark.usefixtures("list_public")
# def test_tasks_put_public(gid):
#     task = {
#         "gid": gid,
#         "tid": str(uuid4()),
#         "title": "book a train ticket",
#         "desc": "blah",
#         "date": 1699182124,
#         "done": False,
#         "tags": ["#areas"],
#     }
#     url = f"http://localhost:8080/apps/maat/api/groups/{gid}/tasks"
#     response = requests.put(url, json=task)
#     assert response.status_code == 200


# @pytest.mark.usefixtures("group")
# def test_tasks_put_unauthorized(gid):
#     task = {
#         "gid": gid,
#         "eid": str(uuid4()),
#         "title": "foo",
#         "amount": "100",
#         "currency": "EUR",
#         "payer": "~zod",
#         "date": 1699182124,
#         "involves": ["~zod"],
#     }
#     url = f"http://localhost:8080/apps/maat/api/groups/{gid}/tasks"
#     response = requests.put(url, json=task)
#     assert response.status_code == 401


# @pytest.mark.usefixtures("group", "member_nus", "task")
# def test_tasks_get(zod, nus, gid, eid, tasks_schema):
#     sleep(0.5)
#     url = f"/apps/maat/api/groups/{gid}/tasks"
#     for pal in (zod, nus):
#         response = pal.get(url)
#         assert response.status_code == 200
#         result = response.json()
#         assert tasks_schema.is_valid(result)
#         assert eid in ([r["eid"] for r in result])


# @pytest.mark.usefixtures("group_public", "task")
# def test_tasks_get_public(gid, eid, tasks_schema):
#     url = f"http://localhost:8080/apps/maat/api/groups/{gid}/tasks"
#     response = requests.get(url)
#     assert response.status_code == 200
#     result = response.json()
#     assert tasks_schema.is_valid(result)
#     assert eid in ([r["eid"] for r in result])


@pytest.mark.usefixtures("list_", "task")
def test_tasks_get_unauthorized(gid, tid):
    url = f"http://localhost:8080/apps/maat/api/lists/{gid}/tasks"
    response = requests.get(url)
    assert response.status_code == 401


@pytest.mark.usefixtures("list_")
def test_task_put_multi(zod, gid, task, tasks_schema):
    """Add multiple tasks by host"""
    task_2 = {
        "gid": gid,
        "tid": str(uuid4()),
        "title": "book a train ticket (return)",
        "desc": "blah",
        "date": 1699182124,
        "done": False,
        "tags": ["#areas"],
    }
    url = f"/apps/maat/api/lists/{gid}/tasks"
    response = zod.put(url, json=task_2)

    # GET /tasks
    response = zod.get(url)
    assert response.status_code == 200
    result = response.json()
    assert tasks_schema.is_valid(result)
    assert set([task["tid"], task_2["tid"]]) <= set([r["tid"] for r in result])


# @pytest.mark.usefixtures("group", "member")
# def test_task_put_by_nus(zod, nus, gid, uuid, task_schema):
#     sleep(0.5)  # wait for successful join
#     task = {
#         "gid": gid,
#         "eid": uuid,
#         "title": "foo",
#         "amount": "100",
#         "currency": "EUR",
#         "payer": "~zod",
#         "date": 1699182124,
#         "involves": ["~zod"],
#     }
#     url = f"/apps/maat/api/groups/{gid}/tasks"

#     # PUT /tasks by nus
#     response = nus.put(url, json=task)
#     assert response.status_code == 200
#     sleep(0.5)  # wait for successful poke

#     # GET /tasks for zod
#     for ship in (zod, nus):
#         response = ship.get(url + "/" + uuid)
#         assert response.status_code == 200
#         result = response.json()
#         assert task_schema.is_valid(result)
#         task["amount"] = 100
#         assert task == result


@pytest.mark.usefixtures("list_", "task")
def test_task_delete(zod, gid, tid):
    # DELETE /tasks/{eid}
    url = f"/apps/maat/api/lists/{gid}/tasks/{tid}"
    response = zod.delete(url)
    assert response.status_code == 200

    # GET /tasks
    url = f"/apps/maat/api/lists/{gid}/tasks"
    response = zod.get(url)
    assert response.status_code == 200
    result = response.json()
    ids = [r["tid"] for r in result]
    assert tid not in ids


# @pytest.mark.usefixtures("group", "member", "task")
# def test_task_delete_by_nus(zod, nus, gid, eid):
#     # DELETE /tasks/{eid} by nus
#     sleep(0.5)  # wait for successful join
#     url = f"/apps/maat/api/groups/{gid}/tasks/{eid}"
#     response = nus.delete(url)
#     assert response.status_code == 200

#     # GET /tasks for zod and nus
#     sleep(0.5)  # wait for successful poke
#     url = f"/apps/maat/api/groups/{gid}/tasks"
#     for ship in (zod, nus):
#         response = ship.get(url)
#         assert response.status_code == 200
#         result = response.json()
#         ids = [r["eid"] for r in result]
#         assert eid not in ids


# @pytest.mark.usefixtures("group_public", "task")
# def test_task_delete_public(zod, gid, eid):
#     # DELETE /tasks/{eid}
#     url = f"http://localhost:8080/apps/maat/api/groups/{gid}/tasks/{eid}"
#     response = requests.delete(url)
#     assert response.status_code == 200

#     # GET /tasks
#     url = f"/apps/maat/api/groups/{gid}/tasks"
#     response = zod.get(url)
#     assert response.status_code == 200
#     result = response.json()
#     ids = [r["eid"] for r in result]
#     assert eid not in ids


@pytest.mark.usefixtures("list_", "task")
def test_task_delete_unauthorized(gid, tid):
    # DELETE /tasks/{eid}
    url = f"http://localhost:8080/apps/maat/api/lists/{gid}/tasks/{tid}"
    response = requests.delete(url)
    assert response.status_code == 401
