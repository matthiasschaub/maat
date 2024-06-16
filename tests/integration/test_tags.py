import pytest


@pytest.mark.usefixtures("list_")
def test_tasks_get_none(zod, gid):
    url = f"/apps/maat/api/lists/{gid}/tags"
    response = zod.get(url)
    assert response.status_code == 200
    result = response.json()
    assert result == []


@pytest.mark.usefixtures("list_", "task")
def test_tasks_get_single(zod, gid):
    url = f"/apps/maat/api/lists/{gid}/tags"
    response = zod.get(url)
    assert response.status_code == 200
    result = response.json()
    assert "areas" in result


@pytest.mark.usefixtures("list_", "task", "task_2")
def test_tasks_get_multiple(zod, gid):
    url = f"/apps/maat/api/lists/{gid}/tags"
    response = zod.get(url)
    assert response.status_code == 200
    result = response.json()
    assert "areas" in result
    assert "resources" in result
    assert result.count("areas") == 1
