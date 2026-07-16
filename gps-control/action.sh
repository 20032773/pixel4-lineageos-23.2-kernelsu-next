#!/system/bin/sh

MODDIR=${0%/*}
current=$(cat "$MODDIR/state" 2>/dev/null)
case "$current" in
    isolate) next=normal ;;
    *) next=isolate ;;
esac
sh "$MODDIR/controller.sh" set "$next"
