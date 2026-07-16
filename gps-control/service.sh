#!/system/bin/sh

MODDIR=${0%/*}
mode=$(cat "$MODDIR/state" 2>/dev/null)
case "$mode" in
    gnss_block|approximate|app_block|all_off)
        sh "$MODDIR/controller.sh" set "$mode" >> "$MODDIR/boot.log" 2>&1
        ;;
esac
