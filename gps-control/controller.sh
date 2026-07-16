#!/system/bin/sh

MODDIR=${0%/*}
STATE="$MODDIR/state"
SERVICES="$MODDIR/stopped-services"
TARGET_FILE="$MODDIR/target-package"
APPOPS_BACKUP="$MODDIR/appops-backup"
DEFAULT_TARGET=com.nianticlabs.pokemongo

valid_package() {
    case "$1" in
        ''|*[!A-Za-z0-9._]*) return 1 ;;
        *) return 0 ;;
    esac
}

target_package() {
    target=$(cat "$TARGET_FILE" 2>/dev/null)
    valid_package "$target" || target="$DEFAULT_TARGET"
    printf '%s\n' "$target"
}

save_target() {
    valid_package "$1" || {
        echo "Invalid Android package name" >&2
        return 2
    }
    pm path "$1" >/dev/null 2>&1 || {
        echo "Package is not installed: $1" >&2
        return 3
    }
    reset_target_ops
    printf '%s\n' "$1" > "$TARGET_FILE"
}

gnss_services() {
    getprop | sed -n 's/^\[init\.svc\.\([^]]*\)\]: \[running\]$/\1/p' |
        grep -Ei '(^|[._-])(gnss|gps)([._-]|$)' || true
}

stop_gnss() {
    : > "$SERVICES"
    gnss_services | while IFS= read -r service; do
        [ -n "$service" ] || continue
        stop "$service"
        echo "$service" >> "$SERVICES"
    done
    if [ ! -s "$SERVICES" ]; then
        echo "No running GNSS init service was detected" >&2
        return 4
    fi
}

start_gnss() {
    if [ -s "$SERVICES" ]; then
        while IFS= read -r service; do
            [ -n "$service" ] && start "$service"
        done < "$SERVICES"
    else
        getprop | sed -n 's/^\[init\.svc\.\([^]]*\)\]: \[stopped\]$/\1/p' |
            grep -Ei '(^|[._-])(gnss|gps)([._-]|$)' |
            while IFS= read -r service; do start "$service"; done
    fi
    rm -f "$SERVICES"
}

read_uid_mode() {
    package="$1"
    operation="$2"
    label="$3"
    cmd appops get --uid "$package" "$operation" 2>/dev/null |
        sed -n "s/^Uid mode: $label: //p" | head -n 1
}

backup_target_ops() {
    [ -s "$APPOPS_BACKUP" ] && return
    package=$(target_package)
    fine=$(read_uid_mode "$package" android:fine_location FINE_LOCATION)
    coarse=$(read_uid_mode "$package" android:coarse_location COARSE_LOCATION)
    [ -n "$fine" ] || fine=default
    [ -n "$coarse" ] || coarse=default
    {
        echo "package=$package"
        echo "fine=$fine"
        echo "coarse=$coarse"
    } > "$APPOPS_BACKUP"
}

reset_target_ops() {
    [ -s "$APPOPS_BACKUP" ] || return 0
    package=$(sed -n 's/^package=//p' "$APPOPS_BACKUP")
    fine=$(sed -n 's/^fine=//p' "$APPOPS_BACKUP")
    coarse=$(sed -n 's/^coarse=//p' "$APPOPS_BACKUP")
    valid_package "$package" || return 0
    cmd appops set --uid "$package" android:fine_location "${fine:-default}" 2>/dev/null || true
    cmd appops set --uid "$package" android:coarse_location "${coarse:-default}" 2>/dev/null || true
    rm -f "$APPOPS_BACKUP"
}

set_mode() {
    mode="$1"
    package=$(target_package)

    case "$mode" in
        normal)
            cmd location set-location-enabled true
            start_gnss
            reset_target_ops
            ;;
        gnss_block)
            cmd location set-location-enabled true
            reset_target_ops
            stop_gnss
            ;;
        approximate)
            cmd location set-location-enabled true
            start_gnss
            backup_target_ops
            cmd appops set --uid "$package" android:coarse_location foreground
            cmd appops set --uid "$package" android:fine_location ignore
            ;;
        app_block)
            cmd location set-location-enabled true
            start_gnss
            backup_target_ops
            cmd appops set --uid "$package" android:fine_location ignore
            cmd appops set --uid "$package" android:coarse_location ignore
            ;;
        all_off)
            start_gnss
            reset_target_ops
            cmd location set-location-enabled false
            ;;
        *)
            echo "Unknown mode: $mode" >&2
            return 2
            ;;
    esac

    printf '%s\n' "$mode" > "$STATE"
    echo "mode=$mode"
    echo "target=$package"
    [ "$mode" = gnss_block ] && echo "stopped_services=$(tr '\n' ',' < "$SERVICES" | sed 's/,$//')"
}

status() {
    mode=$(cat "$STATE" 2>/dev/null)
    [ -n "$mode" ] || mode=normal
    echo "mode=$mode"
    echo "target=$(target_package)"
    echo "location_enabled=$(cmd location is-location-enabled 2>/dev/null)"
    echo "gnss_services=$(getprop | sed -n 's/^\[init\.svc\.\([^]]*gnss[^]]*\)\]: \[\([^]]*\)\]$/\1:\2/ip' | tr '\n' ',' | sed 's/,$//')"
}

case "$1" in
    status) status ;;
    target) save_target "$2" && status ;;
    set) set_mode "$2" ;;
    *) echo "Usage: $0 status | target PACKAGE | set MODE" >&2; exit 2 ;;
esac
