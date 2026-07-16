#!/system/bin/sh

GAME=com.nianticlabs.pokemongo
cmd game reset "$GAME" >/dev/null 2>&1 || true
