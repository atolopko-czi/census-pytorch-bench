find profiling_db -name '*json' -exec cat {} \; | jq -s '[.[] | { command, timestamp, exit_status, elapsed_time_sec, max_res_set_sz_kb }] | sort_by(.timestamp)' |less
