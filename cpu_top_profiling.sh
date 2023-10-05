#!/bin/bash

PID="$1"
LOG_FILE="$2"
if [ -z "$PID" ] || [ -z "$LOG_FILE" ]; then
	echo "Usage: $0 PID LOG_FILE"
	exit 1
fi

MAX_CPU=0

#echo "    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND" > $LOG_FILE
while true ; do

    CPU_USAGE=($(top -n 1 -d .1 | grep $PID | sed -e 's/ \+/ /g' | awk '{print $(NF-4)}'))
    if [[ -z $CPU_USAGE ]]; then
        echo "PID is not found. Closed or not running"
        exit 1
    fi

    if (( $(echo "$CPU_USAGE > $MAX_CPU" |bc -l) )); then
        MAX_CPU="$CPU_USAGE"
        echo "$(date) // Max cpu usage: $MAX_CPU" | tee -a $LOG_FILE
    fi

    sleep 1

done
