#!/system/bin/sh

MODDIR=${0%/*}
current=$(cat "$MODDIR/state" 2>/dev/null)
case "$current" in
    gnss_block) next=normal ;;
    *) next=gnss_block ;;
esac
sh "$MODDIR/controller.sh" set "$next"
