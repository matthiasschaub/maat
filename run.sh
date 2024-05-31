#!/bin/bash
alacritty --command \
    npm run build \
    &
alacritty --command \
    poetry run \
    pilothouse chain zod maat \
    &
sleep 1
alacritty --command \
    poetry run \
    pilothouse chain nus maat \
    &
# sleep 1
# alacritty --command \
#     poetry run \
#     pilothouse chain lus tahuti \
#     &
