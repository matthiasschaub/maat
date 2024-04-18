from hypothesis import given, settings, strategies


@settings(deadline=None)
@given(
    title=strategies.text(min_size=1),
    uuid=strategies.uuids(),
    public=strategies.booleans(),
)
def test_lists_put(uuid, title, public, zod):
    list_ = {
        "id": str(uuid),
        "title": title,
        "host": "~zod",
        "public": public,
    }
    url = "/apps/maat/api/lists"
    # PUT /groups
    response = zod.put(url, json=list_)
    assert response.status_code == 200

    response = zod.get(url)
    assert response.status_code == 200
    result = response.json()
    # because of example shrinking by hypothesis multiple groups with the same
    # UUID but different title are tried out but not found in result since only
    # the first one is successfully created
    #
    # assert group in result
    assert str(uuid) in [r["id"] for r in result]
