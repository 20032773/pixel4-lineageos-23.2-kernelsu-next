#!/system/bin/sh

MODDIR=${0%/*}
GAME=com.nianticlabs.pokemongo

# Keep the game's FPS unrestricted. The lower render scale reduces GPU work
# without changing the panel refresh-rate preference or imposing an FPS cap.
cmd game set --fps 0 --downscale 0.85 "$GAME" >/dev/null 2>&1 || true
cmd game mode custom "$GAME" >/dev/null 2>&1 || true

(
    while true; do
        # Reapply lower-only caps because Power HAL boosts may rewrite sysfs.
        # post-fs-data.sh never raises a limit selected by thermal control.
        sh "$MODDIR/post-fs-data.sh"
        sleep 15
    done
) &
