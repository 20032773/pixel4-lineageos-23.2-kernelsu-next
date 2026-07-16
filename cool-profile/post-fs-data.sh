#!/system/bin/sh

MODDIR=${0%/*}
LOGFILE="$MODDIR/cool-profile.log"

cap_max_if_higher() {
    path="$1"
    cap="$2"
    label="$3"

    [ -r "$path" ] && [ -w "$path" ] || {
        echo "$label unavailable: $path" >> "$LOGFILE"
        return
    }

    current=$(cat "$path")
    if [ "$current" -gt "$cap" ]; then
        echo "$cap" > "$path"
    fi
    echo "$label max=$(cat "$path") cap=$cap" >> "$LOGFILE"
}

{
    echo "=== $(date '+%F %T') ==="
    echo "Applying balanced cool profile without changing thermal controls"
} > "$LOGFILE"

# Snapdragon 855: efficiency, performance and prime clusters.
cap_max_if_higher /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq 1632000 CPU0
cap_max_if_higher /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq 1920000 CPU4
cap_max_if_higher /sys/devices/system/cpu/cpufreq/policy7/scaling_max_freq 2131200 CPU7

# Adreno 640: one step below the stock 585 MHz peak.
cap_max_if_higher /sys/class/kgsl/kgsl-3d0/devfreq/max_freq 499200000 GPU
