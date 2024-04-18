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
def gid():
    return str(uuid4())


@pytest.fixture
def list_(zod, gid) -> dict:
    list_ = {
        "id": gid,
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
        "id": gid,
        "title": "assembly",
        "host": "~zod",
        "public": True,
    }
    url = "/apps/maat/api/lists"
    zod.put(url, json=list_)
    return list_
