# Deployment

## First-time setup

1. Create and boot a moon on the local machine
    - `|moon` to generate moon name and key on the planet
    - `./urbit -w <moon-name> -G <key>` on local machine
2. On the moon: Add desk and distribute the application
    - `|merge %maat our %base`
    - `|mount %maat`
    - `|commit %maat`
    - `|public %maat`
3. On the planet: Sync from the moon: `|sync %maat ~marsed-lasbyt-talfus-laddus %maat`
4. On the planet: Publish the app: `:treaty|publish %maat`
5. Shutdown the moon on the local machine

## Release a new version

1. Bump version numbers in `desk.docket-0` and `maat-api.hoon`
2. Boot the moon
3. `|commit` the changes
4. On the planet: Sync from the moon: `|sync %maat ~marsed-lasbyt-talfus-laddus %maat`

The planet will automatically retrieve those updates and distribute them.

Thanks `~tiller-tolbus` for the initial instructions.
