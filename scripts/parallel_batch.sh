#!/bin/bash

source ./config.env

DATA_DIR="../data/incoming"
PROCESSED_DIR="../data/processed"
FAILED_DIR="../data/failed"
LOG_DIR="../logs"

mkdir -p "$PROCESSED_DIR" "$FAILED_DIR" "$LOG_DIR"

echo "🚀 並行處理開始 $(date '+%F %T')"

# 使用 parallel 處理每個 csv
ls "$DATA_DIR"/*.csv | parallel -j 4 "python3 ../scripts/process_csv.py {}"

# 初始化統計變數
success=0
fail=0

# 根據 log 結果搬移檔案並計數
for file in "$DATA_DIR"/*.csv; do
    fname=$(basename "$file")
    log="$LOG_DIR/${fname%.csv}.log"

    if grep -q "ERROR" "$log"; then
        echo "❌ $fname → failed"
        mv "$file" "$FAILED_DIR/"
        ((fail++))
    else
        echo "✅ $fname → success"
        mv "$file" "$PROCESSED_DIR/"
        ((success++))
    fi
done

echo "📊 彙總報告："
echo "✅ 成功：$success"
echo "❌ 失敗：$fail"

