find profiling_db -name '*json' -exec cat {} \; | jq -s '[.[] | { command, timestamp, exit_status, elapsed_time_sec }] | sort_by(.timestamp)' |less
