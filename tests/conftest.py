import pytest
from .utils import BaseUrlSession
from uuid import uuid4


@pytest.fixture(scope="session")
def zod():
    """Request session for ~zod which is authenticated"""
    baseUrl = "http://localhost:8080"
    data = {"password": "lidlut-tabwed-pillex-ridrup"}
    with BaseUrlSession(baseUrl) as session:
        session.post("/~/login", data=data)  # perform the login
        yield session


@pytest.fixture(scope="session")
def nus():
    """Request session for ~nus which is authenticated"""
    baseUrl = "http://localhost:8081"
    data = {"password": "bortem-pinwyl-macnyx-topdeg"}
    with BaseUrlSession(baseUrl) as session:
        session.post("/~/login", data=data)  # perform the login
        yield session


@pytest.fixture(scope="session")
def lus():
    """Request session for ~nus which is authenticated"""
    baseUrl = "http://localhost:8082"
    data = {"password": "macsyr-davfed-tanrux-linnec"}
    with BaseUrlSession(baseUrl) as session:
        session.post("/~/login", data=data)  # perform the login
        yield session


@pytest.fixture
def uuid():
    return str(uuid4())


@pytest.fixture
def tid():
    return str(uuid4())


@pytest.fixture
def tid_2():
    return str(uuid4())


@pytest.fixture
def gid():
    return str(uuid4())


@pytest.fixture
def list_(zod, gid) -> dict:
    list_ = {
        "gid": gid,
        "title": "assembly",
        "host": "~zod",
        "public": False,
    }
    url = "/apps/maat/api/lists"
    zod.put(url, json=list_)
    return list_


@pytest.fixture
def list_public(zod, gid) -> dict:
    list_ = {
        "gid": gid,
        "title": "assembly",
        "host": "~zod",
        "public": True,
    }
    url = "/apps/maat/api/lists"
    zod.put(url, json=list_)
    return list_


@pytest.fixture
def task(zod, gid, tid) -> dict:
    task = {
        "gid": gid,
        "tid": tid,
        "title": "book a train ticket",
        "desc": "blah",
        "date": 1699182124,
        "done": False,
        "tags": ["areas"],
    }
    url = f"/apps/maat/api/lists/{gid}/tasks"
    zod.put(url, json=task)
    return task


@pytest.fixture
def task_2(zod, gid, tid_2) -> dict:
    task = {
        "gid": gid,
        "tid": tid_2,
        "title": "book a train ticket",
        "desc": "blah",
        "date": 1699182124,
        "done": False,
        "tags": ["areas", "resources"],
    }
    url = f"/apps/maat/api/lists/{gid}/tasks"
    zod.put(url, json=task)
    return task


@pytest.fixture
def invitee_nus(zod, gid):
    url = f"/apps/maat/api/lists/{gid}/invitees"
    response = zod.put(url, json={"invitee": "~nus"})
    return "~nus"


@pytest.fixture
def member_nus(nus, gid, list_, invitee_nus):
    join = {
        "host": list_["host"],
        "gid": gid,
    }
    url = "/apps/maat/api/join"
    response = nus.post(url, json=join)
    return "~nus"
    return "~nus"
