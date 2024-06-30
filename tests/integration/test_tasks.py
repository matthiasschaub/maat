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
        "tags": ["areas"],
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
    assert response.status_code in (500, 422)


@pytest.mark.usefixtures("list_")
def test_tasks_put(zod, gid):
    task = {
        "gid": gid,
        "tid": str(uuid4()),
        "title": "book a train ticket",
        "desc": "blah",
        "date": 1699182124,
        "done": False,
        "tags": ["areas"],
    }

    url = f"/apps/maat/api/lists/{gid}/tasks"
    response = zod.put(url, json=task)
    assert response.status_code == 200


@pytest.mark.usefixtures("list_")
def test_tasks_put_unauthorized(gid):
    task = {
        "gid": gid,
        "eid": str(uuid4()),
        "title": "foo",
        "amount": "100",
        "currency": "EUR",
        "payer": "~zod",
        "date": 1699182124,
        "involves": ["~zod"],
    }
    url = f"http://localhost:8080/apps/maat/api/lists/{gid}/tasks"
    response = requests.put(url, json=task)
    assert response.status_code == 401


@pytest.mark.usefixtures("list_public")
def test_tasks_put_unauthorized_public(gid):
    task = {
        "gid": gid,
        "tid": str(uuid4()),
        "title": "book a train ticket",
        "desc": "blah",
        "date": 1699182124,
        "done": False,
        "tags": ["areas"],
    }
    url = f"http://localhost:8080/apps/maat/api/lists/{gid}/tasks"
    response = requests.put(url, json=task)
    assert response.status_code == 401


@pytest.mark.usefixtures("list_", "task")
def test_tasks_get_all(zod, gid, tid, tasks_schema):
    url = f"/apps/maat/api/lists/{gid}/tasks"
    response = zod.get(url)
    assert response.status_code == 200
    result = response.json()
    assert tasks_schema.is_valid(result)
    assert tid in ([r["tid"] for r in result])


@pytest.mark.usefixtures("list_")
def test_tasks_get_single(zod, gid, tid, task, task_schema):
    url = f"/apps/maat/api/lists/{gid}/tasks/{tid}"
    response = zod.get(url)
    assert response.status_code == 200
    result = response.json()
    assert task_schema.is_valid(result)
    assert task == result


@pytest.mark.usefixtures("list_")
def test_tasks_update(zod, gid, tid, task):
    task2 = {
        "gid": gid,
        "tid": tid,
        "title": "book a train ticket",
        "desc": "blah blah",
        "date": 1699182124,
        "done": True,
        "tags": ["areas"],
    }
    assert task != task2

    url = f"/apps/maat/api/lists/{gid}/tasks/{tid}"
    response = zod.get(url)
    result = response.json()
    assert result == task

    url = f"/apps/maat/api/lists/{gid}/tasks"
    zod.put(url, json=task2)
    url = f"/apps/maat/api/lists/{gid}/tasks/{tid}"
    response = zod.get(url)
    result = response.json()
    assert result == task2


@pytest.mark.usefixtures("list_", "task", "member_nus")
def test_tasks_get_all_by_nus(nus, gid, tid, tasks_schema):
    sleep(0.5)
    url = f"/apps/maat/api/lists/{gid}/tasks"
    response = nus.get(url)
    assert response.status_code == 200
    result = response.json()
    assert tasks_schema.is_valid(result)
    assert tid in ([r["tid"] for r in result])


@pytest.mark.usefixtures("list_", "task")
def test_tasks_get_filter_undone(zod, gid, tid, tasks_schema):
    url = f"/apps/maat/api/lists/{gid}/tasks"
    params = {"done": "false"}
    response = zod.get(url, params=params)
    assert response.status_code == 200
    result = response.json()
    assert tasks_schema.is_valid(result)
    assert tid in ([r["tid"] for r in result])


@pytest.mark.usefixtures("list_", "task")
def test_tasks_get_filter_done(zod, gid, tid, tasks_schema):
    url = f"/apps/maat/api/lists/{gid}/tasks"
    params = {"done": "true"}
    response = zod.get(url, params=params)
    assert response.status_code == 200
    result = response.json()
    assert tasks_schema.is_valid(result)
    assert tid not in ([r["tid"] for r in result])


@pytest.mark.usefixtures("list_", "task")
def test_tasks_get_filter_tag(zod, gid, tid, tasks_schema):
    url = f"/apps/maat/api/lists/{gid}/tasks"
    params = {"tags": ["areas"]}
    response = zod.get(url, params=params)
    assert response.status_code == 200
    result = response.json()
    assert tasks_schema.is_valid(result)
    assert tid in ([r["tid"] for r in result])


@pytest.mark.usefixtures("list_", "task")
def test_tasks_get_filter_some_tag(zod, gid, tid, tasks_schema):
    url = f"/apps/maat/api/lists/{gid}/tasks"
    params = {"tags": ["some"]}
    response = zod.get(url, params=params)
    assert response.status_code == 200
    result = response.json()
    assert tasks_schema.is_valid(result)
    assert tid not in ([r["tid"] for r in result])


@pytest.mark.usefixtures("list_", "task")
def test_tasks_get_filter_no_tag(zod, gid, tid, tasks_schema):
    url = f"/apps/maat/api/lists/{gid}/tasks"
    params = {"tags": []}
    response = zod.get(url, params=params)
    assert response.status_code == 200
    result = response.json()
    assert tasks_schema.is_valid(result)
    assert tid in ([r["tid"] for r in result])


@pytest.mark.usefixtures("list_", "task")
def test_tasks_get_filter_multiple_tags_or(zod, gid, tid, tasks_schema):
    """Get all tasks if any one tag matches (OR)"""
    url = f"/apps/maat/api/lists/{gid}/tasks"
    params = {"tags": ["areas", "projects"]}
    response = zod.get(url, params=params)
    assert response.status_code == 200
    result = response.json()
    assert tasks_schema.is_valid(result)
    assert tid in ([r["tid"] for r in result])


# @pytest.mark.usefixtures("list_", "task")
# def test_tasks_get_filter_multiple_tags_and(zod, gid, tid, tasks_schema):
#     """Get all tasks if any one tag matches (AND)"""
#     # TODO
#     url = f"/apps/maat/api/lists/{gid}/tasks"
#     params = {"tags": ["areas", "projects"]}
#     response = zod.get(url, params=params)
#     assert response.status_code == 200
#     result = response.json()
#     assert tasks_schema.is_valid(result)
#     assert tid not in ([r["tid"] for r in result])


@pytest.mark.usefixtures("list_", "task")
def test_tasks_get_unauthorized(gid, tid):
    url = f"http://localhost:8080/apps/maat/api/lists/{gid}/tasks"
    response = requests.get(url)
    assert response.status_code == 401


@pytest.mark.usefixtures("list_public", "task")
def test_tasks_get_public(gid, tid, tasks_schema):
    url = f"http://localhost:8080/apps/maat/api/lists/{gid}/tasks"
    response = requests.get(url)
    assert response.status_code == 200
    result = response.json()
    assert tasks_schema.is_valid(result)
    assert tid in ([r["tid"] for r in result])


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
        "tags": ["areas"],
    }
    url = f"/apps/maat/api/lists/{gid}/tasks"
    response = zod.put(url, json=task_2)

    # GET /tasks
    response = zod.get(url)
    assert response.status_code == 200
    result = response.json()
    assert tasks_schema.is_valid(result)
    assert set([task["tid"], task_2["tid"]]) <= set([r["tid"] for r in result])


@pytest.mark.usefixtures("list_", "member_nus")
def test_task_put_by_nus(zod, nus, gid, uuid, task_schema):
    sleep(0.5)  # wait for successful join
    task = {
        "gid": gid,
        "tid": uuid,
        "title": "book a train ticket (return)",
        "desc": "blah",
        "date": 1699182124,
        "done": False,
        "tags": ["areas"],
    }
    url = f"/apps/maat/api/lists/{gid}/tasks"

    # PUT /tasks by nus
    response = nus.put(url, json=task)
    assert response.status_code == 200
    # sleep(0.5)  # wait for successful poke

    # GET /tasks for zod
    for ship in (zod, nus):
        response = ship.get(url + "/" + uuid)
        assert response.status_code == 200
        result = response.json()
        assert task_schema.is_valid(result)
        assert task == result


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


@pytest.mark.usefixtures("list_", "member_nus", "task")
def test_task_delete_by_nus(zod, nus, gid, tid):
    # DELETE /tasks/{tid} by nus
    sleep(0.5)  # wait for successful join
    url = f"/apps/maat/api/lists/{gid}/tasks/{tid}"
    response = nus.delete(url)
    assert response.status_code == 200

    # GET /tasks for zod and nus
    sleep(0.5)  # wait for successful poke
    url = f"/apps/maat/api/lists/{gid}/tasks"
    for ship in (zod, nus):
        response = ship.get(url)
        assert response.status_code == 200
        result = response.json()
        ids = [r["tid"] for r in result]
        assert tid not in ids


@pytest.mark.usefixtures("list_", "task")
def test_task_delete_unauthorized(gid, tid):
    # DELETE /tasks/{eid}
    url = f"http://localhost:8080/apps/maat/api/lists/{gid}/tasks/{tid}"
    response = requests.delete(url)
    assert response.status_code == 401


@pytest.mark.usefixtures("list_public", "task")
def test_task_delete_unauthorized_public(gid, tid):
    # DELETE /tasks/{tid}
    url = f"http://localhost:8080/apps/maat/api/lists/{gid}/tasks/{tid}"
    response = requests.delete(url)
    assert response.status_code == 401
