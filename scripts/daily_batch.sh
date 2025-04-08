#!/bin/bash

DATA_DIR="/home/ff_pc/dev/projects/linux-for-dataengineer/data/incoming"
LOG_DIR="/home/ff_pc/dev/projects/linux-for-dataengineer/logs"

mkdir -p "$LOG_DIR"

echo "🚀 Batch started at $(date '+%F %T')"

for file in "$DATA_DIR"/*.csv; do
    echo "🔄 處理檔案：$file"
    python3 /home/ff_pc/dev/projects/linux-for-dataengineer/scripts/process_csv.py "$file"
done

echo "✅ 處理完畢，開始掃描 log 是否出錯"

for logfile in "$LOG_DIR"/*.log; do
    if grep -q "ERROR" "$logfile"; then
        echo "❌ 發現錯誤: $logfile"
    else
        echo "✅ 無錯誤: $logfile"
    fi
done

echo "🏁 批次處理完成"

