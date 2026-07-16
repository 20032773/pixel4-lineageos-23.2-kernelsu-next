#!/system/bin/sh

# Re-apply once during late_start. Never raise a limit that thermal control has
# already lowered, so this profile cannot defeat stock thermal throttling.
MODDIR=${0%/*}
sh "$MODDIR/post-fs-data.sh"
