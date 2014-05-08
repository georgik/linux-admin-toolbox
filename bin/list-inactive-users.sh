#!/bin/bash

ACTIVE_LIST="/tmp/active-list.txt"
CLEAN_LIST="/tmp/clean-list.txt"
SYSTEM_LIST="/tmp/system-list.txt"
echo "" > "$ACTIVE_LIST"

for LOG_FILE in /var/log/wtmp*; do
    echo "Processing: $LOG_FILE"
    last -f "$LOG_FILE" | sed -e 's/ .*//g' | grep -v wtmp | sort |uniq >> "$ACTIVE_LIST"
done

for LOG_FILE in /var/log/mail.log*; do
    echo "Processing: $LOG_FILE"
    zgrep LOGOUT "$LOG_FILE" |sed -e 's/.*user=\([^,]*\),.*/\1/g' -e 's/@.*//g' | grep -v LOGOUT | sort | uniq >>"$ACTIVE_LIST"
done

cat "$ACTIVE_LIST" | sort | uniq > "$CLEAN_LIST"

cat /etc/shadow | sed -e 's/:.*//g' | sort > "$SYSTEM_LIST"

diff "$CLEAN_LIST" "$SYSTEM_LIST" --left-column | grep '>' | sed -e 's/> //g' | sort |uniq
