import pytest
import requests


@pytest.mark.usefixtures("list_")
def test_lists(zod):
    # GET /lists
    url = "http://localhost:8080/apps/maat"
    response = zod.get(url)
    assert response.status_code == 200


@pytest.mark.usefixtures("list_")
def test_lists_unauthorized():
    # GET /lists
    url = "http://localhost:8080/apps/maat"
    response = requests.get(url, allow_redirects=False)
    assert response.status_code == 302


@pytest.mark.usefixtures("list_public")
def test_lists_public_unauthorized():
    # GET /lists
    url = "http://localhost:8080/apps/maat"
    response = requests.get(url, allow_redirects=False)
    assert response.status_code == 302


@pytest.mark.usefixtures("list_")
def test_tasks(zod, gid):
    # GET /lists
    url = f"http://localhost:8080/apps/maat/lists/{gid}/tasks"
    response = zod.get(url)
    assert response.status_code == 200


@pytest.mark.usefixtures("list_")
def test_tasks_unauthorized(gid):
    # GET /lists
    url = f"http://localhost:8080/apps/maat/lists/{gid}/tasks"
    response = requests.get(url, allow_redirects=False)
    assert response.status_code == 302


@pytest.mark.usefixtures("list_public")
def test_tasks_public(gid):
    # GET /lists
    url = f"http://localhost:8080/apps/maat/lists/{gid}/tasks"
    response = requests.get(url, allow_redirects=False)
    assert response.status_code == 200


@pytest.mark.usefixtures("list_", "task")
def test_tasks_edit(zod, gid, tid):
    # GET /lists
    url = f"http://localhost:8080/apps/maat/lists/{gid}/tasks/{tid}/edit"
    response = zod.get(url)
    assert response.status_code == 200


@pytest.mark.usefixtures("list_", "task")
def test_tasks_edit_unauthorized(gid, tid):
    # GET /lists
    url = f"http://localhost:8080/apps/maat/lists/{gid}/tasks/{tid}/edit"
    response = requests.get(url, allow_redirects=False)
    assert response.status_code == 302


@pytest.mark.usefixtures("list_public", "task")
def test_tasks_edit_public(gid, tid):
    # GET /lists
    url = f"http://localhost:8080/apps/maat/lists/{gid}/tasks/{tid}/edit"
    response = requests.get(url, allow_redirects=False)
    assert response.status_code == 302


@pytest.mark.usefixtures("list_")
def test_tasks(zod, gid):
    # GET /lists
    url = f"http://localhost:8080/apps/maat/lists/{gid}/settings"
    response = zod.get(url)
    assert response.status_code == 200


@pytest.mark.usefixtures("list_")
def test_tasks_unauthorized(gid):
    # GET /lists
    url = f"http://localhost:8080/apps/maat/lists/{gid}/settings"
    response = requests.get(url, allow_redirects=False)
    assert response.status_code == 302


@pytest.mark.usefixtures("list_public")
def test_tasks_public(gid):
    # GET /lists
    url = f"http://localhost:8080/apps/maat/lists/{gid}/settings"
    response = requests.get(url, allow_redirects=False)
    assert response.status_code == 302
