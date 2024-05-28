#!/bin/bash
poetry run \
    pilothouse run marsed-lasbyt-talfus-laddus/
alacritty --command \
    poetry run \
    pilothouse sync marsed-lasbyt-talfus-laddus/ maat/ \
    &
sleep 2
poetry run \
    pilothouse commit marsed-lasbyt-talfus-laddus/ maat/
