memwatch() {
    local pid=$1
    local interval=${2:-2}

    if [ -z "$pid" ]; then
        echo "Usage: memwatch <pid> [interval_seconds]"
        return 1
    fi

    if ! kill -0 "$pid" 2>/dev/null; then
        echo "No process with PID $pid"
        return 1
    fi

    echo "Monitoring PID $pid (interval: ${interval}s) — Ctrl+C to stop"
    printf "%-10s %-14s %s\n" "Time" "RSS (MB)" "PIDs"

    local peak_kb=0

    while kill -0 "$pid" 2>/dev/null; do
        local all_pids
        all_pids=$(pstree -p "$pid" | grep -oP '\(\K[0-9]+')

        if [ -z "$all_pids" ]; then
            all_pids=$pid
        fi

        local total_kb
        total_kb=$(ps -o rss= -p "$(echo "$all_pids" | paste -sd,)" 2>/dev/null \
                    | awk '{s+=$1} END {print s+0}')
        local nprocs
        nprocs=$(echo "$all_pids" | wc -l)

        local total_mb
        total_mb=$(awk -v kb="$total_kb" 'BEGIN { printf "%.1f", kb / 1024 }')

        printf "%-10s %-14s %s\n" "$(date +%T)" "$total_mb MB" "($nprocs procs)"

        if [ "$total_kb" -gt "$peak_kb" ]; then
            peak_kb=$total_kb
        fi

        sleep "$interval"
    done

    local peak_mb
    peak_mb=$(awk -v kb="$peak_kb" 'BEGIN { printf "%.1f", kb / 1024 }')
    echo "---"
    echo "Process $pid exited. Peak RSS: $peak_mb MB"
}
