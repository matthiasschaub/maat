"""Backup and restore Maat tasks."""

import os
import json
from pathlib import Path
import click

from .utils import BaseUrlSession
from requests.exceptions import HTTPError


@click.group()
def cli():
    pass


@cli.command("backup")
@click.option("--url", type=str, required=True, help="Base URL of your ship.")
@click.option("--gid", type=str, required=True, help="Existing list ID.")
@click.option(
    "--file",
    type=click.Path(
        exists=False,
        dir_okay=False,
        file_okay=True,
        path_type=Path,
    ),
    required=True,
    help="Output JSON file.",
)
@click.option(
    "--access-code", type=str, required=False, help="Access code of your ship."
)
def backup(url, gid: str, file: Path, access_code: None | str):
    """Backup tasks of a list."""
    if access_code is None:
        try:
            access_code = os.environ.get("MAAT_ACCESS_CODE")
        except KeyError:
            click.echo(
                "Please provide the access code to your ship as option or as an "
                "environment variable (`MAAT_ACCESS_CODE`)"
            )
            return
    session = auth(url, access_code)
    endpoint = f"/apps/maat/api/lists/{gid}/tasks"
    # PUT /tasks
    click.echo("Backup tasks")
    response = session.get(endpoint)
    response.raise_for_status()
    data = response.json()
    with open(file, "w") as f:
        json.dump(data, f)
    click.echo("Done")


@cli.command("restore")
@click.option("--url", type=str, required=True, help="Base URL of your ship.")
@click.option("--gid", type=str, required=True, help="New list ID.")
@click.option(
    "--file",
    type=click.Path(
        exists=True,
        dir_okay=False,
        file_okay=True,
        path_type=Path,
    ),
    required=True,
    help="Input JSON file.",
)
@click.option(
    "--access-code", type=str, required=False, help="Access code of your ship."
)
def restore(url, gid: str, file: Path, access_code: None | str):
    """Restore tasks of a list."""
    if access_code is None:
        try:
            access_code = os.environ.get("TAHUTI_ACCESS_CODE")
        except KeyError:
            click.echo(
                "Please provide the access code to your ship as option or as an "
                "environment variable (`MAAT_ACCESS_CODE`)"
            )
            return
    session = auth(url, access_code)
    endpoint = f"/apps/maat/api/lists/{gid}/tasks"
    with open(file, "r") as f:
        data = json.load(f)
    # PUT /tasks
    with click.progressbar(
        data,
        label="Restore tasks",
    ) as bar:
        for task in bar:
            task["gid"] = gid
            response = session.put(endpoint, json=task)
            response.raise_for_status()
    click.echo("Done")


def auth(url, password):
    click.echo("Authenticate")
    data = {"password": password}
    with BaseUrlSession(url) as session:
        response = session.post("/~/login", data=data)  # perform the login
        try:
            response.raise_for_status()
        except HTTPError:
            click.echo("Authetication failed")
            # TODO: ABORT
        return session


if __name__ == "__main__":
    cli()
