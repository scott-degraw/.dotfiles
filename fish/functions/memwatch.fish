function memwatch --description 'Monitor memory of a PID and its subprocess tree'
    # Args
    set pid $argv[1]
    set interval (test (count $argv) -ge 2; and echo $argv[2]; or echo 2)

    if test -z "$pid"
        echo "Usage: memwatch <pid> [interval_seconds]"
        return 1
    end

    if not kill -0 $pid 2>/dev/null
        echo "No process with PID $pid"
        return 1
    end

    echo "Monitoring PID $pid (interval: {$interval}s) — Ctrl+C to stop"
    printf "%-10s %-14s %s\n" "Time" "RSS (MB)" "PIDs"

    set peak_kb 0

    while kill -0 $pid 2>/dev/null
        # Get all PIDs in the process tree
        set all_pids (pstree -p $pid | grep -oP '\(\K[0-9]+')

        if test (count $all_pids) -eq 0
            set all_pids $pid
        end

        # Sum RSS across all PIDs
        set total_kb (ps -o rss= -p (string join ',' $all_pids) 2>/dev/null \
                      | awk '{s+=$1} END {print s+0}')

        set total_mb (math -s1 "$total_kb / 1024")
        set nprocs (count $all_pids)

        printf "%-10s %-14s %s\n" (date +%T) "$total_mb MB" "($nprocs procs)"

        if test $total_kb -gt $peak_kb
            set peak_kb $total_kb
        end

        sleep $interval
    end

    set peak_mb (math -s1 "$peak_kb / 1024")
    echo "---"
    echo "Process $pid exited. Peak RSS: $peak_mb MB"
end
