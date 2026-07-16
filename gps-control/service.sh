#!/system/bin/sh

MODDIR=${0%/*}
mode=$(cat "$MODDIR/state" 2>/dev/null)
case "$mode" in
    weaken|isolate)
        sh "$MODDIR/controller.sh" set "$mode" >> "$MODDIR/boot.log" 2>&1
        ;;
esac
