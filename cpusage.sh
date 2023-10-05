#!/bin/bash
PID=$1
if [ -z "$PID" ]; then
	echo Usage: $0 PID
	exit 1
fi

LOG_FILE="$2"

# İlk değer atamaları
avg=0
t=1

while true ; do
	if [ -e "/proc/$PID/stat" ]; then
		PROCESS_STAT=($(sed -E 's/\([^)]+\)/X/' "/proc/$PID/stat"))
		PROCESS_UTIME=${PROCESS_STAT[13]}
		PROCESS_STIME=${PROCESS_STAT[14]}
		PROCESS_STARTTIME=${PROCESS_STAT[21]}
		SYSTEM_UPTIME_SEC=$(tr . ' ' </proc/uptime | awk '{print $1}')
	else
		echo "Error: /proc/$PID/stat file not found or cannot be read."
		exit 1
	fi
	
	#echo "PROCESS_STAT: $PROCESS_STAT"
	#echo "PROCESS_UTIME: $PROCESS_UTIME"
	#echo "PROCESS_STIME: $PROCESS_STIME"
	#echo "PROCESS_STARTTIME: $PROCESS_STARTTIME"
	
	CLK_TCK=$(getconf CLK_TCK)
	
# Set LC_NUMERIC to C to ensure proper number formatting
	LC_NUMERIC=C

# Calculate values using bc
	PROCESS_UTIME_SEC=$(echo "scale=4; $PROCESS_UTIME / $CLK_TCK" | bc)
	PROCESS_STIME_SEC=$(echo "scale=4; $PROCESS_STIME / $CLK_TCK" | bc)
	PROCESS_STARTTIME_SEC=$(echo "scale=4; $PROCESS_STARTTIME / $CLK_TCK" | bc)

	PROCESS_ELAPSED_SEC=$(echo "scale=4; $SYSTEM_UPTIME_SEC - $PROCESS_STARTTIME_SEC" | bc)
	PROCESS_USAGE_SEC=$(echo "scale=4; $PROCESS_UTIME_SEC + $PROCESS_STIME_SEC" | bc)
	PROCESS_USAGE=$(echo "scale=4; $PROCESS_USAGE_SEC * 100 / $PROCESS_ELAPSED_SEC" | bc)

	# Reset LC_NUMERIC to the default value
	LC_NUMERIC=

	date >> "$LOG_FILE"
	echo "user mode: ${PROCESS_UTIME_SEC}s , kernel mode: ${PROCESS_STIME_SEC}s. Total CPU usage: ${PROCESS_USAGE_SEC}s" >> "$LOG_FILE"
	echo "Process running for ${PROCESS_ELAPSED_SEC}s. Process CPU usage ${PROCESS_USAGE}%" >> "$LOG_FILE"

	# Değeri ortalamaya ekleyin(iterative ortalama hesaplaması)
	avg=$(awk -v x="$PROCESS_USAGE" -v avg="$avg" -v t="$t" 'BEGIN{print (avg + (x - avg) / (t))}')
	# Toplam değeri bir artırın
  ((t++))
	echo "average $PROCESS_USAGE" >> "$LOG_FILE"
	echo "">> "$LOG_FILE"
	sleep 1
done
