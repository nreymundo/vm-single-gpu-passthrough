#!/bin/bash
# Allocate 32 GiB of hugepages (16,384 x 2 MiB)

TARGET_PAGES=16384
RETRIES=5
SLEEP_SEC=1

allocate_hugepages() {
    echo "$1" | sudo tee /proc/sys/vm/nr_hugepages > /dev/null
}

clear_cache() {
    echo 1 | sudo tee /proc/sys/vm/drop_caches > /dev/null
}

echo "[INFO] Requesting $TARGET_PAGES hugepages..."
for attempt in $(seq 1 "$RETRIES"); do
    allocate_hugepages "$TARGET_PAGES"

    actual_pages=$(grep HugePages_Total /proc/meminfo | awk '{print $2}')
    free_pages=$(grep HugePages_Free /proc/meminfo | awk '{print $2}')

    if [[ "$actual_pages" -ge "$TARGET_PAGES" && "$free_pages" -ge "$TARGET_PAGES" ]]; then
        echo "[SUCCESS] Hugepages successfully allocated."
        exit 0
    fi

    echo "[WARN] Allocation incomplete (have $free_pages/$TARGET_PAGES). Retrying ($attempt/$RETRIES)..."
    clear_cache
    sleep "$SLEEP_SEC"
done

echo "[ERROR] Hugepages allocation failed after $RETRIES retries."
exit 1

