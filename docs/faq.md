# Frequently Asked Questions (FAQ)

## How can I backup my tasks?

You can download all tasks of a list as JSON file on the settings page.

Alternatively, you can use the command-line tool `maat` to download the
tasks:

```bash
> pipx install git+https://github.com/matthiasschaub/maat.git
> maat backup --help 
Usage: maat backup [OPTIONS]

  Backup tasks of a list.

Options:
  --url TEXT          Base URL of your ship.  [required]
  --gid TEXT          Existing list ID.  [required]
  --file FILE         Output JSON file.  [required]
  --access-code TEXT  Access code of your ship.
  --help              Show this message and exit.
> # access code can also be provided as env
> export MAAT_ACCESS_CODE=mycode
> maat backup \
    --url https://sample-palnet.tlon.network \
    --gid ca14e82a-ad2f-487e-9f59-fe373bbadd9c \
    --file tasks.json
```

See also [How can I restore my backup?](#how-can-i-restore-my-backup)

## How can I restore my backup?

The general process to restore tasks of a list is to create a new list,
invite all previous members and import tasks from JSON file.

Unfortunately, importing tasks can not be done from the web interface yet.
Right now, the only way to do it is to use the command-line tool `maat` to
restore your backup:

```bash
> pipx install git+https://github.com/matthiasschaub/maat.git
> maat restore --help
Usage: maat restore [OPTIONS]

  Restore tasks of a list.

Options:
  --url TEXT          Base URL of your ship.  [required]
  --gid TEXT          New list ID.  [required]
  --file FILE         Input JSON file.  [required]
  --access-code TEXT  Access code of your ship.
  --help              Show this message and exit.
> # access code can also be provided as env
> export maat_ACCESS_CODE=mycode
> maat restore \
    --url https://sample-palnet.tlon.network \
    --gid ca14e82a-ad2f-487e-9f59-fe373bbadd9c \
    --file tasks.json
```

See also [How can I backup my tasks?](#how-can-i-backup-my-tasks)
