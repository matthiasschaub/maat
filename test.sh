MAAT_ACCESS_CODE="$(pass talfus-laddus/code)"
export TAHUTI_ACCESS_CODE
export MAAT_ACCESS_CODE
maat backup \
    --url https://ship.talfus-laddus.de \
    --gid 185acb93-8166-4447-94fe-c8ec7b2fdcce \
    --file "$HOME/.backup/maat-$(date -I).json"
