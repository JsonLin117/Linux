#!/bin/bash

# 啟動 venv
source /home/ff_pc/dev/projects/linux-for-dataengineer/.venv/bin/activate

# 建立 log 目錄
mkdir -p /home/ff_pc/dev/projects/linux-for-dataengineer/logs

# 建立當天 log 檔案
log_file="/home/ff_pc/dev/projects/linux-for-dataengineer/logs/$(date +%F).log"

# 寫入 log function
log() {
    echo "$(date '+%F %T') - $1" >> "$log_file"
}

log "🚀 Pipeline started."

# 抓目前小時
hour=$(date +%H)

# 判斷偶數 or 奇數小時
if [ $((10#$hour % 2)) -eq 0 ]; then
    result="Yes"
else
    result="No"
fi

log "⏱️ Current hour: $hour → Result: $result"

# 假設錯誤條件：如果現在是奇數小時，就當成錯誤退出
if [ "$result" = "No" ]; then
    log "❌ 偵測到奇數小時，Pipeline 模擬失敗，結束任務。"
    exit 1
fi

log "✅ Pipeline completed successfully."
