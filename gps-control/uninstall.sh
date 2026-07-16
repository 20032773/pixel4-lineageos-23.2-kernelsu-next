#!/system/bin/sh

MODDIR=${0%/*}
sh "$MODDIR/controller.sh" set normal >/dev/null 2>&1 || true
