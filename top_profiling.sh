#!/bin/bash

PID="$1"
COLON="$2"
LOG_FILE="$3"
if [ -z $COLON ]; then
    COLON=8
    echo "Using default COLON value $COLON"
fi

if [ -z "$PID" ] || [ -z "$LOG_FILE" ]; then
	echo "Usage: $0 PID COLON LOG_FILE"
    echo "Your top command could be different. Look for the column you are looking for"
	exit 1
fi

MAX=0

while true ; do

    USAGE=($(top -n 1 -d .1 | grep $PID | sed -e 's/ \+/ /g' | awk -v COL="$COLON" '{print $(COL)}'))
    if [[ -z $USAGE ]]; then
        echo "PID is not found. Closed or not running"
        exit 1
    fi

    echo "$(date) // top command column($COLON) usage: $USAGE" 2>&1 | tee -a $LOG_FILE 

    if (( $(echo "$USAGE > $MAX" |bc -l) )); then
        MAX="$USAGE"
        echo "$(date) // top command column($COLON) Max usage: $MAX" 2>&1 | tee -a $LOG_FILE
    fi

    sleep 1

done
