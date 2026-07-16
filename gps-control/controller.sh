#!/system/bin/sh

MODDIR=${0%/*}
STATE="$MODDIR/state"
GNSS_BACKUP="$MODDIR/stopped-gnss-services"
ASSIST_BACKUP="$MODDIR/stopped-assistance-services"

running_services() {
    getprop | sed -n 's/^\[init\.svc\.\([^]]*\)\]: \[running\]$/\1/p'
}

gnss_services() {
    running_services | grep -Ei '(^|[._-])(gnss|gps)([._-]|$)' || true
}

assistance_services() {
    running_services | grep -Ei '(^|[._-])(loc_launcher|xtra|izat)([._-]|$)' || true
}

stop_list() {
    detector="$1"
    backup="$2"
    : > "$backup"
    $detector | while IFS= read -r service; do
        [ -n "$service" ] || continue
        stop "$service"
        echo "$service" >> "$backup"
    done
}

restore_list() {
    backup="$1"
    [ -s "$backup" ] || return 0
    while IFS= read -r service; do
        [ -n "$service" ] && start "$service"
    done < "$backup"
    rm -f "$backup"
}

restore_all() {
    restore_list "$GNSS_BACKUP"
    restore_list "$ASSIST_BACKUP"
}

set_mode() {
    mode="$1"
    case "$mode" in
        normal)
            restore_all
            ;;
        weaken)
            restore_list "$GNSS_BACKUP"
            restore_list "$ASSIST_BACKUP"
            # Remove cached assistance, then stop only auxiliary location
            # services. The real GNSS HAL and Android location stay enabled.
            cmd location providers send-extra-command gps delete_aiding_data >/dev/null 2>&1 || true
            stop_list assistance_services "$ASSIST_BACKUP"
            [ -s "$ASSIST_BACKUP" ] || {
                echo "No GNSS assistance service was detected on this ROM" >&2
                return 4
            }
            ;;
        isolate)
            restore_all
            stop_list gnss_services "$GNSS_BACKUP"
            [ -s "$GNSS_BACKUP" ] || {
                echo "No running GNSS HAL service was detected on this ROM" >&2
                return 5
            }
            ;;
        *) echo "Unknown mode: $mode" >&2; return 2 ;;
    esac

    printf '%s\n' "$mode" > "$STATE"
    status
}

service_state() {
    pattern="$1"
    getprop | sed -n "s/^\[init\.svc\.\([^]]*${pattern}[^]]*\)\]: \[\([^]]*\)\]$/\1:\2/ip" |
        tr '\n' ',' | sed 's/,$//'
}

status() {
    mode=$(cat "$STATE" 2>/dev/null)
    case "$mode" in normal|weaken|isolate) ;; *) mode=normal ;; esac
    echo "mode=$mode"
    echo "location_enabled=$(cmd location is-location-enabled 2>/dev/null)"
    echo "gnss=$(service_state gnss)"
    echo "assistance=$(service_state loc_launcher)"
}

case "$1" in
    status) status ;;
    set) set_mode "$2" ;;
    *) echo "Usage: $0 status | set normal|weaken|isolate" >&2; exit 2 ;;
esac
