# Architecture

## Agents

There are three agents:

- `%maat-ui`: UI agent. Serves front-end (HTML, CSS, JS and HTMX).
- `%maat-api`: REST API agent. Interfaces with front-end via requests with JSON payload.
- `%maat`: Core agent. Manages state (lists, tasks and subscriptions).

### %tahuti-ui

Inspired by [%feature](https://docs.urbit.org/userspace/apps/examples/feature)
Depends on [%schooner](https://github.com/urbit/yard/blob/main/desk/lib/schooner.hoon)

The front-end is build with HTML, CSS, JS and HTMX.
HTMX is used to interfaces with the API using JSON encoded request bodies
(`json-enc` extension) and client side templates (`mustache.json`).

### %tahuti-api

Inspired by [%feature](https://docs.urbit.org/userspace/apps/examples/feature)
Depends on [%schooner](https://github.com/urbit/yard/blob/main/desk/lib/schooner.hoon)

Endpoints:
```
GET   api/lists                          // Get all lists                (JSON array)
PUT   api/lists                          // Add or edit a list           (JSON object)
GET   api/lists/{uuid}                   // Get a list                   (JSON object)
```

## Abbreviations

- lid: list ID
- tid: task ID
- reg: register (of members)
- acl: access-control list
