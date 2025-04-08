# 🧠 Linux 大神之路 Day 2：資源控制・排程・Shell Script 實戰技巧

## 🌟 主題一：程式 & 資源控制═Process & Resource Control

Data Engineer 總是會執行資源密集的任務，例如：
- Spark Job
- Docker container
- Airflow DAG
- 大型 ETL script

### ⛏️ 常用指令整理

| 指令 | 用途 |
|------|------|
| `top` / `htop` | 觀察 CPU / 記憶體 |
| `ps aux` / `ps -ef` | 查看執行中的程式 |
| `kill PID` | 終止當掉的程式 |
| `time python script.py` | 測試執行時間 |
| `du -sh *` / `df -h` | 看資料夾大小 / 磁碟空間 |
| `iotop` | 監控 I/O 使用情況 |
| `nmon` | 圖形化系統監控 |

### 🧢 實際應用場景

- `top`：觀察 Spark Job 吃光 CPU
- `ps aux | grep airflow`：找到卡住的 Airflow DAG
- `kill -9 PID`：強制終止錯誤服務
- `df -h`：報表沒跑出來因為磁碟滿了
- `time script.py`：分析資料轉換 script 花多少時間

### 🔍 監控工具進階使用

#### htop 進階操作
| 快捷鍵 | 功能 |
|-------|------|
| `F3` | 搜尋程序 |
| `F4` | 過濾程序 |
| `F5` | 樹狀結構顯示 |
| `F6` | 排序選項 |
| `F9` | 殺死程序 |
| `u` | 依使用者過濾 |
| `t` | 樹狀/一般顯示切換 |

#### iotop 監控磁碟 I/O
```bash
sudo apt install iotop
sudo iotop                # 即時監控 I/O 使用情況
sudo iotop -o             # 只顯示有 I/O 活動的程序
```

#### nmon 圖形化監控
```bash
sudo apt install nmon
nmon                      # 啟動互動式監控
# 按 c 顯示 CPU, m 顯示記憶體, d 顯示磁碟, n 顯示網路
```

---

## ✅ Day 2 練習情境與解法說明

### 📊 主題一：程式 & 資源控制實戰

#### 🔍 情境一：找出並終止佔用資源過高的程序

**情境說明：**
你的 Spark 任務執行時間異常長，需要找出是哪個程序佔用了過多資源並進行處理。

```bash
# 步驟 1: 使用 top 觀察系統資源
top

# 步驟 2: 找到 PID 並查看詳細資訊
ps -ef | grep 12345

# 步驟 3: 嘗試正常終止程序
kill 12345

# 步驟 4: 如果程序無法正常終止，強制終止
kill -9 12345
```

**技術解釋：**
- `top`：即時顯示系統資源使用情況，按 `P` 可依 CPU 使用率排序
- `ps -ef | grep PID`：查看特定程序的詳細資訊，包括啟動命令
- `kill PID`：發送 SIGTERM 信號，請求程序正常終止
- `kill -9 PID`：發送 SIGKILL 信號，強制終止程序（最後手段）

#### 🔍 情境二：分析磁碟空間問題

**情境說明：**
某個 ETL 任務突然失敗，錯誤訊息顯示「No space left on device」，需要快速找出佔用空間的目錄。

```bash
# 步驟 1: 檢查磁碟使用情況
df -h

# 步驟 2: 找出大型目錄
du -sh /*

# 步驟 3: 深入分析特定目錄
cd /var/log
du -sh * | sort -hr | head -10

# 步驟 4: 清理不需要的檔案
rm -f old_logs/*.gz
```

**技術解釋：**
- `df -h`：以人類可讀格式顯示所有掛載點的空間使用情況
- `du -sh /*`：顯示根目錄下各個目錄的總大小
- `sort -hr`：依大小排序（h 表示人類可讀，r 表示降序）
- `head -10`：只顯示前 10 個最大的項目

#### 🔍 情境三：監控 I/O 效能問題

**情境說明：**
資料處理任務執行緩慢，懷疑是 I/O 瓶頸導致，需要找出哪些程序佔用了大量 I/O。

```bash
# 步驟 1: 安裝並啟動 iotop
sudo apt install iotop
sudo iotop -o

# 步驟 2: 觀察 I/O 使用情況
# 找出 I/O 讀寫量大的程序

# 步驟 3: 調整程序優先級
ionice -c2 -n7 -p 12345
```

**技術解釋：**
- `iotop -o`：只顯示有 I/O 活動的程序，便於找出問題
- `ionice`：調整程序的 I/O 優先級，減少對系統的影響
  - `-c2`：使用最佳效能調度類別
  - `-n7`：設定較低的優先級（0-7，7 最低）
  - `-p PID`：指定要調整的程序 ID

---

## 🌟 主題二：排程與自動化（cron）

讓你的程式「定時自動執行」，常用於：
- 每天跑報表
- 每小時同步資料
- 每月清理 log

### 📘 cron 基礎語法

```
* * * * * command
│ │ │ │ └─ 週期 (0=Sun)
│ │ │ └── 月份
│ │ └─── 月內日期
│ └───── 小時 (0–23)
└─────── 分鐘 (0–59)
```

### 🛠 常用指令

| 指令 | 用途 |
|------|------|
| `crontab -e` | 編輯排程任務 |
| `crontab -l` | 查看任務清單 |
| `>> log 2>&1` | 將輸出寫入 log（含錯誤） |

### ❗cron 注意事項（新手地雷）

#### 環境變數不同
cron 跑的環境變數比你平常開 terminal 少！像 Python venv、PATH、PYTHONPATH 等都可能要手動指定。

```bash
# 在 crontab 中設定環境變數
PATH=/usr/local/bin:/usr/bin:/bin
PYTHONPATH=/path/to/your/project

# 或在腳本中設定
0 9 * * * cd /path/to/project && source venv/bin/activate && python script.py
```

#### script 開頭記得設定 shebang
```bash
#!/bin/bash
```
不然可能無法正確執行。

#### 記得 log 要寫完整路徑
```bash
0 9 * * * /path/to/script.sh >> /path/to/logs/cron.log 2>&1
```
否則錯誤你也不知道發生了什麼事。

#### 測試 cron 腳本技巧
```bash
# 1. 先手動執行確認沒問題
bash /path/to/script.sh

# 2. 確認權限
chmod +x /path/to/script.sh

# 3. 使用絕對路徑
which python  # 找出 python 的絕對路徑
```

### 🧪 範例任務

| 排程時間 | 指令 |
|---------|------|
| 每天早上 9 點 | 0 9 * * * |
| 每 5 分鐘 | */5 * * * * |
| 每週一早上 8 點 | 0 8 * * 1 |
| 每月 1 號 0 點 | 0 0 1 * * |

```bash
0 9 * * * bash ~/scripts/run_report.sh >> logs/cron_$(date +\%F).log 2>&1
```

👉 log 檔名每日不同  
👉 `\%F` 要 escape `%` 才能在 cron 中生效

### 📆 主題二：排程與自動化實戰

#### 🔍 情境一：每日自動備份資料庫

**情境說明：**
你需要每天凌晨 2 點自動備份 PostgreSQL 資料庫，並保留最近 7 天的備份。

```bash
# 步驟 1: 建立備份腳本 db_backup.sh
cat > ~/scripts/db_backup.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="/backup/postgres"
DATETIME=$(date +%Y%m%d_%H%M%S)
DB_NAME="mydb"

# 確保備份目錄存在
mkdir -p $BACKUP_DIR

# 執行備份
pg_dump $DB_NAME | gzip > "$BACKUP_DIR/${DB_NAME}_${DATETIME}.sql.gz"

# 刪除 7 天前的備份
find $BACKUP_DIR -name "${DB_NAME}_*.sql.gz" -mtime +7 -delete

echo "備份完成: $BACKUP_DIR/${DB_NAME}_${DATETIME}.sql.gz"
EOF

# 步驟 2: 設定執行權限
chmod +x ~/scripts/db_backup.sh

# 步驟 3: 設定 crontab
crontab -e
# 加入以下行
0 2 * * * /home/user/scripts/db_backup.sh >> /home/user/logs/backup_$(date +\%F).log 2>&1
```

**技術解釋：**
- `crontab -e`：編輯當前用戶的 cron 任務
- `0 2 * * *`：每天凌晨 2 點執行
- `pg_dump`：PostgreSQL 資料庫備份工具
- `find ... -mtime +7 -delete`：找出並刪除 7 天前的檔案
- `>> /home/user/logs/backup_$(date +\%F).log 2>&1`：將標準輸出和錯誤輸出記錄到日期命名的日誌檔

#### 🔍 情境二：監控服務狀態並自動重啟

**情境說明：**
你有一個重要的 API 服務需要確保 24/7 運行，需要每 5 分鐘檢查一次，如果服務停止則自動重啟。

```bash
# 步驟 1: 建立監控腳本 monitor_service.sh
cat > ~/scripts/monitor_service.sh << 'EOF'
#!/bin/bash

SERVICE_NAME="my-api-service"
LOG_FILE="/var/log/service_monitor.log"

# 檢查服務狀態
if ! systemctl is-active --quiet $SERVICE_NAME; then
    echo "$(date): $SERVICE_NAME 已停止，嘗試重啟..." >> $LOG_FILE
    
    # 嘗試重啟服務
    systemctl restart $SERVICE_NAME
    
    # 檢查重啟是否成功
    if systemctl is-active --quiet $SERVICE_NAME; then
        echo "$(date): $SERVICE_NAME 重啟成功" >> $LOG_FILE
        # 發送成功通知
        curl -X POST -H "Content-Type: application/json" \
             -d '{"text":"服務已自動重啟成功"}' \
             https://hooks.slack.com/services/YOUR_WEBHOOK_URL
    else
        echo "$(date): $SERVICE_NAME 重啟失敗，需要人工介入" >> $LOG_FILE
        # 發送失敗警報
        curl -X POST -H "Content-Type: application/json" \
             -d '{"text":"警告：服務重啟失敗，請立即檢查！"}' \
             https://hooks.slack.com/services/YOUR_WEBHOOK_URL
    fi
fi
EOF

# 步驟 2: 設定執行權限
chmod +x ~/scripts/monitor_service.sh

# 步驟 3: 設定 crontab
crontab -e
# 加入以下行
*/5 * * * * /home/user/scripts/monitor_service.sh
```

**技術解釋：**
- `*/5 * * * *`：每 5 分鐘執行一次
- `systemctl is-active --quiet`：靜默檢查服務是否運行中
- `systemctl restart`：重啟系統服務
- `curl -X POST`：發送 webhook 通知到 Slack 或其他平台

#### 🔍 情境三：定時資料同步與清理

**情境說明：**
你需要每小時從外部 API 獲取新數據，處理後存入本地資料庫，並在每週日清理舊數據。

```bash
# 小時任務：資料同步
0 * * * * cd /path/to/project && source venv/bin/activate && python sync_data.py >> /var/log/data_sync/hourly_$(date +\%F).log 2>&1

# 週任務：清理舊數據
0 0 * * 0 cd /path/to/project && source venv/bin/activate && python cleanup_old_data.py --days 30 >> /var/log/data_sync/cleanup_$(date +\%F).log 2>&1
```

**技術解釋：**
- `0 * * * *`：每小時整點執行
- `0 0 * * 0`：每週日午夜執行
- `cd /path/to/project && source venv/bin/activate`：切換到專案目錄並啟動虛擬環境
- `--days 30`：傳遞參數給清理腳本，指定清理 30 天前的數據

---

## 🌟 主題三：Shell Script 流程控制技巧

讓你的 script 更靈活、更像小型應用程式！

### ⛏️ 技巧清單

| 技術 | 用途 |
|------|------|
| `if [ ... ]` | 判斷條件 |
| `for`, `while` | 迴圈控制流程 |
| `source .venv/bin/activate` | 啟動虛擬環境 |
| `log_file="$(date +%F).log"` | 動態 log 檔命名 |
| `curl + jq` | 打 API + 解析 JSON |
| `exit 1` | 錯誤時中止流程 |

### 🧪 實作範例

```bash
if [ $((10#$hour % 2)) -eq 0 ]; then
    echo "YES"
else
    echo "NO"
fi
```

搭配：
- `curl` 發通知
- `grep` 找 ERROR 再停止流程

### 🚀 Shell Script 進階技巧

#### 函數定義與使用
```bash
# 定義函數
function check_status {
    if [ $1 -eq 0 ]; then
        echo "成功: $2"
        return 0
    else
        echo "失敗: $2"
        return 1
    fi
}

# 呼叫函數
check_status $? "資料處理"
```

#### 錯誤處理與退出碼檢查
```bash
set -e                   # 任何指令錯誤就中止腳本
trap 'echo "錯誤發生於第 $LINENO 行"; exit 1' ERR  # 錯誤處理

# 檢查上一個指令的退出碼
command
if [ $? -ne 0 ]; then
    echo "指令失敗，開始清理..."
    # 清理操作
    exit 1
fi
```

#### 參數解析
```bash
while getopts "f:d:h" opt; do
  case $opt in
    f) file="$OPTARG" ;;
    d) date="$OPTARG" ;;
    h) echo "使用方法: $0 -f <檔案> -d <日期>"; exit 0 ;;
    *) echo "未知參數"; exit 1 ;;
  esac
done
```

#### 並行處理
```bash
# 啟動背景任務
for i in {1..5}; do
    process_data "file$i" &
    pids[$i]=$!
done

# 等待所有任務完成
for pid in ${pids[*]}; do
    wait $pid
done
```

### 💼 主題三：Shell Script 流程控制實戰

#### 🔍 情境一：for 讀取資料夾內所有檔案：批次處理任務

**情境說明：**
你有多個 `.csv` 檔案在資料夾中，想要自動讀取每一個檔案並交給 Python script 處理。

```bash
#!/bin/bash
# process_all_csv.sh

DATA_DIR="/path/to/data"
OUTPUT_DIR="/path/to/output"
LOG_FILE="processing_$(date +%F).log"

# 確保輸出目錄存在
mkdir -p $OUTPUT_DIR

# 記錄開始時間
echo "[開始處理] $(date)" > $LOG_FILE

# 計算檔案數量
TOTAL_FILES=$(find $DATA_DIR -name "*.csv" | wc -l)
echo "發現 $TOTAL_FILES 個 CSV 檔案要處理" >> $LOG_FILE

# 計數器
COUNT=0

# 遍歷所有 CSV 檔案
for file in $DATA_DIR/*.csv; do
    filename=$(basename "$file")
    COUNT=$((COUNT + 1))
    
    echo "[$COUNT/$TOTAL_FILES] 處理 $filename..." >> $LOG_FILE
    
    # 呼叫 Python 處理腳本
    python3 process_csv.py "$file" "$OUTPUT_DIR" >> $LOG_FILE 2>&1
    
    # 檢查處理結果
    if [ $? -eq 0 ]; then
        echo "  ✅ 成功處理 $filename" >> $LOG_FILE
    else
        echo "  ❌ 處理 $filename 失敗" >> $LOG_FILE
    fi
done

echo "[完成] $(date) - 共處理 $COUNT 個檔案" >> $LOG_FILE
```

**技術解釋：**
- `for file in $DATA_DIR/*.csv`：loop 遍歷所有 csv 檔案
- `basename "$file"`：取得檔案名稱（不含路徑）
- `python3 process_csv.py "$file" "$OUTPUT_DIR"`：每個檔案作為參數交給 script 處理
- `if [ $? -eq 0 ]`：檢查上一個命令的執行結果（0 表示成功）
- 適用於每日資料批次處理、報表生成任務

#### 🔍 情境二：while loop 模擬監控任務（log 監控、自動重試）

**情境說明：**
你希望定期掃描某個 log 檔案是否出現「ERROR」，如果有就觸發警告或中止流程。

```bash
#!/bin/bash
# monitor_log.sh

LOG_FILE="/var/log/myapp/pipeline.log"
CHECK_INTERVAL=10  # 每 10 秒檢查一次
MAX_ERRORS=3       # 最多允許 3 次錯誤

echo "[開始監控] $(date) - 檢查檔案: $LOG_FILE"

error_count=0

while true; do
  if grep -q "ERROR" "$LOG_FILE"; then
    error_count=$((error_count + 1))
    echo "[警告] $(date) - 偵測到錯誤 ($error_count/$MAX_ERRORS)"
    
    # 擷取錯誤訊息
    error_msg=$(grep "ERROR" "$LOG_FILE" | tail -1)
    echo "  錯誤訊息: $error_msg"
    
    # 發送警報
    curl -s -X POST -H "Content-Type: application/json" \
         -d "{\"text\":\"Pipeline 錯誤: $error_msg\"}" \
         https://hooks.slack.com/services/YOUR_WEBHOOK_URL > /dev/null
    
    # 如果錯誤次數超過限制，停止監控
    if [ $error_count -ge $MAX_ERRORS ]; then
      echo "[停止] $(date) - 錯誤次數超過上限 ($MAX_ERRORS)，結束監控"
      exit 1
    fi
  fi
  
  # 等待一段時間再檢查
  sleep $CHECK_INTERVAL
done
```

**技術解釋：**
- `while true`：無限監控迴圈
- `grep -q "ERROR"`：靜默搜尋是否有包含特定關鍵字（這裡是 ERROR）
- `error_count=$((error_count + 1))`：計算錯誤次數
- `curl -s -X POST`：發送 webhook 通知
- `sleep $CHECK_INTERVAL`：每 10 秒檢查一次，避免 CPU 過度消耗

#### 🔍 情境三：使用函數與參數解析建立通用工具

**情境說明：**
你需要建立一個通用的資料備份工具，可以接受不同的參數來備份不同的目錄或資料庫。

```bash
#!/bin/bash
# backup_tool.sh

# 顯示使用方法
show_usage() {
    echo "用法: $0 [-t type] [-s source] [-d destination] [-r retention_days]"
    echo "  -t: 備份類型 (files 或 database)"
    echo "  -s: 來源路徑或資料庫名稱"
    echo "  -d: 目標路徑"
    echo "  -r: 保留天數 (預設: 7)"
    echo "  -h: 顯示此說明"
    exit 1
}

# 備份檔案
backup_files() {
    local source=$1
    local dest=$2
    local filename="files_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    
    echo "[備份檔案] 來源: $source"
    echo "[備份檔案] 目標: $dest/$filename"
    
    # 創建目標目錄
    mkdir -p "$dest"
    
    # 執行備份
    tar -czf "$dest/$filename" -C "$(dirname "$source")" "$(basename "$source")"
    
    if [ $? -eq 0 ]; then
        echo "[備份檔案] ✅ 成功"
        return 0
    else
        echo "[備份檔案] ❌ 失敗"
        return 1
    fi
}

# 備份資料庫
backup_database() {
    local dbname=$1
    local dest=$2
    local filename="db_backup_$(date +%Y%m%d_%H%M%S).sql.gz"
    
    echo "[備份資料庫] 資料庫: $dbname"
    echo "[備份資料庫] 目標: $dest/$filename"
    
    # 創建目標目錄
    mkdir -p "$dest"
    
    # 執行備份
    pg_dump "$dbname" | gzip > "$dest/$filename"
    
    if [ $? -eq 0 ]; then
        echo "[備份資料庫] ✅ 成功"
        return 0
    else
        echo "[備份資料庫] ❌ 失敗"
        return 1
    fi
}

# 清理舊備份
cleanup_old_backups() {
    local backup_dir=$1
    local days=$2
    local type=$3
    
    echo "[清理] 移除 $days 天前的 $type 備份"
    
    if [ "$type" == "files" ]; then
        find "$backup_dir" -name "files_backup_*.tar.gz" -mtime +$days -delete
    else
        find "$backup_dir" -name "db_backup_*.sql.gz" -mtime +$days -delete
    fi
    
    echo "[清理] 完成"
}

# 預設值
TYPE=""
SOURCE=""
DEST=""
RETENTION=7

# 解析命令列參數
while getopts "t:s:d:r:h" opt; do
    case $opt in
        t) TYPE=$OPTARG ;;
        s) SOURCE=$OPTARG ;;
        d) DEST=$OPTARG ;;
        r) RETENTION=$OPTARG ;;
        h) show_usage ;;
        *) show_usage ;;
    esac
done

# 檢查必要參數
if [ -z "$TYPE" ] || [ -z "$SOURCE" ] || [ -z "$DEST" ]; then
    echo "[錯誤] 缺少必要參數"
    show_usage
fi

# 執行備份
echo "[開始] $(date) - 備份類型: $TYPE"

case $TYPE in
    "files")
        backup_files "$SOURCE" "$DEST"
        RESULT=$?
        ;;
    "database")
        backup_database "$SOURCE" "$DEST"
        RESULT=$?
        ;;
    *)
        echo "[錯誤] 不支援的備份類型: $TYPE"
        exit 1
        ;;
esac

# 清理舊備份
if [ $RESULT -eq 0 ]; then
    cleanup_old_backups "$DEST" "$RETENTION" "$TYPE"
    echo "[完成] $(date) - 備份與清理完成"
    exit 0
else
    echo "[失敗] $(date) - 備份失敗，不執行清理"
    exit 1
fi
```

**使用範例：**
```bash
# 備份檔案
./backup_tool.sh -t files -s /path/to/important/data -d /backup/files -r 14

# 備份資料庫
./backup_tool.sh -t database -s mydb -d /backup/databases -r 30
```

**技術解釋：**
- `function name() { ... }`：定義可重複使用的函數
- `getopts "t:s:d:r:h" opt`：解析命令列參數，冒號表示需要值
- `case $TYPE in ... esac`：根據不同參數執行不同操作
- `local variable`：定義函數內部變數，避免影響全局變數
- `$?`：檢查上一個命令的執行結果

---

## 🌟 主題四：log 分析技巧

#### 常用分析命令
```bash
# 尋找特定字串
grep "ERROR" app.log

# 計算出現次數
grep -c "ERROR" app.log

# 尋找前後行
grep -A 2 -B 2 "ERROR" app.log

# 尋找多個檔案
grep "ERROR" *.log
for f in logs/*.log; do grep -q "ERROR" "$f" && echo "$f 有錯"; done

# 尋找時間範圍
sed -n '/2023-01-01 10:00:00/,/2023-01-01 11:00:00/p' app.log

# 統計 HTTP 狀態碼
awk '{print $9}' access.log | sort | uniq -c | sort -rn
```

### 📊 主題四：log 分析實戰

#### 🔍 情境一：分析 Web 伺服器諏問模式與效能問題

**情境說明：**
你的 Web 應用程式近期出現效能下降，需要分析 Nginx 的諏問日誌來找出原因。

```bash
# 步驟 1: 分析諏問量跟狀態碼分佈
# 每小時諏問量
awk '{print substr($4, 2, 13)}' /var/log/nginx/access.log | sort | uniq -c

# 輸出結果範例
#   156 01/Mar/2023:00
#   243 01/Mar/2023:01
#  1503 01/Mar/2023:02  <- 尖峰時段

# 步驟 2: 查看 HTTP 狀態碼分佈
awk '{print $9}' /var/log/nginx/access.log | sort | uniq -c | sort -rn

# 輸出結果範例
# 15234 200
#  1503 301
#   782 404
#   543 500  <- 服務器內部錯誤

# 步驟 3: 找出哪些 URL 造成 500 錯誤
awk '$9 == 500 {print $7}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head -10

# 輸出結果範例
#  342 /api/reports/generate
#  156 /api/users/profile

# 步驟 4: 查看某個特定 URL 的響應時間
awk '$7 == "/api/reports/generate" {print $7, $10}' /var/log/nginx/access.log | sort -nk2 | tail

# 輸出結果範例 (第二欄是響應時間，單位為毫秒)
# /api/reports/generate 1243
# /api/reports/generate 2851
# /api/reports/generate 5231  <- 非常慢的諏問
```

**技術解釋：**
- `awk '{print substr($4, 2, 13)}'`：擷取日期時間欄位的小時部分
- `sort | uniq -c`：計算每小時的諏問次數
- `$9 == 500`：篩選 HTTP 500 狀態碼的諏問
- `sort -rn`：依數字降序排序（最多的在前面）
- `sort -nk2`：依第二欄的數字升序排序

#### 🔍 情境二：分析應用程式錯誤日誌找出系統異常

**情境說明：**
你的 Java 應用程式在深夜出現異常中止，需要快速分析日誌檔找出原因。

```bash
# 步驟 1: 尋找異常發生的時間點
grep -n "Exception\|Error" /var/log/app/application.log | head

# 輸出結果範例
# 15876:2023-03-02 01:45:23 ERROR [ThreadPoolExecutor-3] - java.lang.OutOfMemoryError: Java heap space

# 步驟 2: 查看異常發生前後的日誌
grep -n -A 10 -B 5 "OutOfMemoryError" /var/log/app/application.log

# 步驟 3: 分析記憶體使用情況
grep "Memory usage" /var/log/app/application.log | tail -50 > memory_usage.txt

# 步驟 4: 尋找特定的大型操作
grep "Processing large dataset" /var/log/app/application.log | grep "$(date -d yesterday +%F)" | wc -l

# 步驟 5: 尋找異常發生前的特定操作
sed -n '/2023-03-02 01:30:00/,/2023-03-02 01:45:23/p' /var/log/app/application.log | grep "dataset\|batch\|memory" > events_before_crash.log
```

**技術解釋：**
- `grep -n`：顯示行號，幫助定位問題
- `grep -A 10 -B 5`：顯示符合條件行的前 5 行和後 10 行
- `grep "$(date -d yesterday +%F)"`：尋找昨天的日期記錄
- `sed -n '/start_time/,/end_time/p'`：擷取指定時間範圍的日誌

#### 🔍 情境三：建立日誌分析腳本作為監控工具

**情境說明：**
你需要建立一個自動化腳本，定期分析日誌檔並生成報表，如果發現异常情況則發送警報。

```bash
#!/bin/bash
# log_analyzer.sh

LOG_DIR="/var/log/app"
REPORT_DIR="/var/reports"
DATE=$(date +%F)
ALERT_THRESHOLD=50  # 錯誤數量警判門檻

# 確保報表目錄存在
mkdir -p $REPORT_DIR

# 創建報表檔案
REPORT_FILE="$REPORT_DIR/log_report_$DATE.txt"

echo "=== 日誌分析報表 - $DATE ===" > $REPORT_FILE
echo "" >> $REPORT_FILE

# 1. 統計錯誤和警告數量
echo "1. 錯誤和警告統計" >> $REPORT_FILE
ERROR_COUNT=$(grep -c "ERROR" $LOG_DIR/application.log)
WARN_COUNT=$(grep -c "WARN" $LOG_DIR/application.log)

echo "   錯誤 (ERROR): $ERROR_COUNT" >> $REPORT_FILE
echo "   警告 (WARN): $WARN_COUNT" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 2. 前 10 個最常見的錯誤
echo "2. 最常見的錯誤類型" >> $REPORT_FILE
grep "ERROR" $LOG_DIR/application.log | awk -F "ERROR" '{print $2}' | cut -d ':' -f1 | sort | uniq -c | sort -rn | head -10 >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 3. 每小時錯誤分佈
echo "3. 每小時錯誤分佈" >> $REPORT_FILE
grep "ERROR" $LOG_DIR/application.log | awk '{print substr($1,1,13)}' | sort | uniq -c >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 4. 系統效能指標
echo "4. 效能指標" >> $REPORT_FILE
echo "   平均響應時間: $(grep "Response time" $LOG_DIR/application.log | awk '{sum+=$NF; count++} END {print sum/count "ms"}')" >> $REPORT_FILE
echo "   最大響應時間: $(grep "Response time" $LOG_DIR/application.log | awk '{print $NF}' | sort -n | tail -1) ms" >> $REPORT_FILE
echo "   交易總數: $(grep -c "Transaction completed" $LOG_DIR/application.log)" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 5. 檢查是否需要發送警報
if [ $ERROR_COUNT -gt $ALERT_THRESHOLD ]; then
    echo "[警報] 錯誤數量 ($ERROR_COUNT) 超過門檻值 $ALERT_THRESHOLD"
    
    # 發送電子郵件警報
    cat $REPORT_FILE | mail -s "[警報] 日誌分析報表 - 錯誤數量超標 - $DATE" admin@example.com
    
    # 或發送 Slack 警報
    curl -X POST -H "Content-Type: application/json" \
         -d "{\"text\":\"[警報] 日誌分析發現 $ERROR_COUNT 個錯誤，超過門檻值 $ALERT_THRESHOLD\"}" \
         https://hooks.slack.com/services/YOUR_WEBHOOK_URL
fi

echo "報表已生成: $REPORT_FILE"
```

**使用方式：**
```bash
# 手動執行分析
./log_analyzer.sh

# 設定為每日自動執行
0 7 * * * /path/to/log_analyzer.sh
```

**技術解釋：**
- `grep -c`：計算符合條件的行數
- `awk -F`：指定欄位分隔符
- `awk '{sum+=$NF; count++} END {print sum/count}'`：計算平均值
- `mail -s`：發送電子郵件警報
- `curl -X POST`：發送 webhook 通知

### 📊 日誌管理進階技巧

#### logrotate 配置
```bash
# /etc/logrotate.d/myapp
/var/log/myapp/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0640 user group
    postrotate
        systemctl reload myapp
    endscript
}
```

#### journalctl 進階使用
```bash
# 按時間查詢
journalctl --since "2023-01-01" --until "2023-01-02"

# 按服務查詢
journalctl -u nginx.service

# 按優先級查詢
journalctl -p err

# 實時追蹤
journalctl -f -u myapp.service
```

#### 日誌分析腳本範例
```bash
#!/bin/bash
# log_analyzer.sh

LOG_DIR="/var/log/myapp"
REPORT_FILE="report_$(date +%F).txt"

echo "===== 錯誤統計 =====" > $REPORT_FILE
grep -c "ERROR" $LOG_DIR/*.log >> $REPORT_FILE

echo -e "\n===== 最常見的錯誤 =====" >> $REPORT_FILE
grep "ERROR" $LOG_DIR/*.log | awk -F': ' '{print $2}' | sort | uniq -c | sort -nr | head -5 >> $REPORT_FILE

echo -e "\n===== 錯誤發生時間分布 =====" >> $REPORT_FILE
grep "ERROR" $LOG_DIR/*.log | awk '{print $1}' | cut -d'T' -f2 | cut -d':' -f1 | sort | uniq -c >> $REPORT_FILE
```

---

## 🌟 主題五：安全性基礎實踐

### 🔒 SSH 金鑰管理
```bash
# 生成 SSH 金鑰
ssh-keygen -t ed25519 -C "your_email@example.com"

# 複製公鑰到遠端伺服器
ssh-copy-id user@remote-server

# 使用金鑰登入
ssh -i ~/.ssh/id_ed25519 user@remote-server
```

#### 🔍 情境一：建立安全的 SSH 金鑰認證機制

**情境說明：**
你需要為多台數據庫伺服器設定安全的無密碼 SSH 連線，並確保只有授權的管理員可以存取。

```bash
# 步驟 1: 產生強密鑰對（使用 ED25519 演算法）
ssh-keygen -t ed25519 -C "dataengineer@company.com"
# 或者使用 RSA 但要指定高位元
ssh-keygen -t rsa -b 4096 -C "dataengineer@company.com"

# 步驟 2: 將公鑰傳送到所有需要管理的伺服器
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@db1.example.com
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@db2.example.com

# 步驟 3: 在遠端伺服器上強化 SSH 設定
sudo nano /etc/ssh/sshd_config

# 修改以下設定
# PasswordAuthentication no        # 禁用密碼登入
# PermitRootLogin prohibit-password # 禁止 root 使用密碼登入
# Protocol 2                       # 只使用 SSH 協議第 2 版

# 步驟 4: 重啟 SSH 服務使設定生效
sudo systemctl restart sshd

# 步驟 5: 創建 SSH 配置檔案簡化連線
cat >> ~/.ssh/config << 'EOF'
Host db1
    HostName db1.example.com
    User datauser
    IdentityFile ~/.ssh/id_ed25519
    Port 22

Host db2
    HostName db2.example.com
    User datauser
    IdentityFile ~/.ssh/id_ed25519
    Port 22
EOF

chmod 600 ~/.ssh/config  # 設定正確的權限

# 步驟 6: 現在可以使用簡化命令連線
ssh db1  # 等同於 ssh -i ~/.ssh/id_ed25519 datauser@db1.example.com
```

**技術解釋：**
- `ssh-keygen -t ed25519`：使用現代的 ED25519 演算法產生密鑰對，比 RSA 更安全且更短
- `ssh-copy-id`：自動將公鑰加到遠端伺服器的 `~/.ssh/authorized_keys` 檔案
- `PasswordAuthentication no`：強制使用金鑰認證，防止暴力破解密碼
- `~/.ssh/config`：簡化 SSH 連線設定，不需要記憶複雜的連線參數

### 🛡️ 檔案權限最佳實踐
```bash
# 敏感檔案設定嚴格權限
chmod 600 ~/.ssh/id_rsa          # 私鑰只有擁有者可讀寫
chmod 644 ~/.ssh/id_rsa.pub      # 公鑰所有人可讀

# 腳本執行權限
chmod 755 /scripts/*.sh          # 腳本可執行但只有擁有者可寫

# 資料目錄權限
chmod -R 750 /data               # 目錄可讀可執行但不可寫給其他人
```

#### 🔍 情境二：為共用數據庫設定安全的檔案權限

**情境說明：**
你的團隊需要在一個共用的 Linux 伺服器上設定一個數據分析工作區，使不同角色的人可以安全地存取和處理數據。

```bash
# 步驟 1: 創建群組和用戶
# 創建群組
sudo groupadd data_analysts
sudo groupadd data_scientists
sudo groupadd data_engineers

# 創建用戶並指定主群組
sudo useradd -m -g data_analysts -s /bin/bash analyst1
sudo useradd -m -g data_scientists -s /bin/bash scientist1
sudo useradd -m -g data_engineers -s /bin/bash engineer1

# 設定密碼
sudo passwd analyst1
sudo passwd scientist1
sudo passwd engineer1

# 步驟 2: 創建資料目錄結構
sudo mkdir -p /data/raw           # 原始數據
sudo mkdir -p /data/processed     # 處理後的數據
sudo mkdir -p /data/analytics     # 分析結果
sudo mkdir -p /data/scripts       # 腳本目錄

# 步驟 3: 設定目錄權限
# 設定根目錄擁有者為 root，群組為 data_engineers
sudo chown -R root:data_engineers /data

# 設定基本權限
sudo chmod 750 /data              # drwxr-x--- 目錄擁有者可讀寫執行，群組可讀執行

# raw 目錄：只有 data_engineers 可寫
sudo chmod 770 /data/raw          # drwxrwx--- 只有 data_engineers 可寫

# processed 目錄：所有群組可讀，data_engineers 和 data_scientists 可寫
sudo chown -R root:data_engineers /data/processed
sudo chmod 770 /data/processed    # drwxrwx---
sudo setfacl -m g:data_scientists:rwx /data/processed  # 給 data_scientists 群組讀寫執行權限

# analytics 目錄：所有群組可讀，data_analysts 可寫
sudo chown -R root:data_analysts /data/analytics
sudo chmod 770 /data/analytics    # drwxrwx---

# scripts 目錄：只有 data_engineers 可寫，但所有人可執行
sudo chown -R root:data_engineers /data/scripts
sudo chmod 755 /data/scripts      # drwxr-xr-x

# 步驟 4: 設定腳本檔案權限
sudo find /data/scripts -type f -name "*.sh" -exec chmod 755 {} \;  # 腳本可執行

# 步驟 5: 創建共用目錄並設定 SGID 位
sudo mkdir -p /data/shared
sudo chown root:data_engineers /data/shared
sudo chmod 2775 /data/shared      # drwxrwsr-x 設定 SGID，確保新創建的檔案繼承群組

# 為其他群組增加存取權限
sudo setfacl -m g:data_scientists:rwx /data/shared
sudo setfacl -m g:data_analysts:rx /data/shared
```

**技術解釋：**
- `chmod 750`：設定權限為 `rwxr-x---`，即擁有者可讀寫執行，群組可讀執行，其他人無權限
- `chown user:group`：變更檔案或目錄的擁有者和群組
- `chmod 2775`：設定 SGID 位，確保在目錄中創建的新檔案繼承目錄的群組
- `setfacl`：設定存取控制清單 (ACL)，提供更精細的權限控制
- `find ... -exec`：尋找所有符合條件的檔案並執行指定的命令

### 🔐 安全性檢查腳本
```bash
#!/bin/bash
# security_check.sh

echo "檢查開放的網路連接..."
netstat -tuln

echo "檢查可疑的 cron 任務..."
for user in $(cut -f1 -d: /etc/passwd); do
  crontab -u $user -l 2>/dev/null
done

echo "檢查敏感檔案權限..."
find /home -name "*.pem" -o -name "*.key" | xargs ls -la
```

#### 🔍 情境三：建立定期安全檢查腳本保護數據伺服器

**情境說明：**
作為一名資料工程師，你需要為公司的數據處理伺服器建立一個全面的安全檢查腳本，定期檢查漏洞並發送報告。

```bash
#!/bin/bash
# comprehensive_security_check.sh

# 設定變數
HOSTNAME=$(hostname)
DATE=$(date +"%Y-%m-%d %H:%M:%S")
REPORT_FILE="/var/log/security/security_report_$(date +%F).txt"
EMAIL="security@company.com"

# 確保日誌目錄存在
mkdir -p /var/log/security

# 開始報告
echo "========================================" > $REPORT_FILE
echo "   安全檢查報告 - $HOSTNAME" >> $REPORT_FILE
echo "   生成時間: $DATE" >> $REPORT_FILE
echo "========================================" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 1. 檢查系統更新
echo "1. 系統更新狀態" >> $REPORT_FILE
echo "----------------------------" >> $REPORT_FILE
apt list --upgradable 2>/dev/null | grep -v "Listing..." >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 2. 檢查開放的網路連接
echo "2. 開放的網路連接" >> $REPORT_FILE
echo "----------------------------" >> $REPORT_FILE
netstat -tuln | grep LISTEN >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 3. 檢查從外部可存取的服務
echo "3. 從外部可存取的服務" >> $REPORT_FILE
echo "----------------------------" >> $REPORT_FILE
netstat -tuln | grep LISTEN | grep -v "127.0.0.1" | grep -v "::1" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 4. 檢查最近的登入失敗嘗試
echo "4. 最近的登入失敗嘗試" >> $REPORT_FILE
echo "----------------------------" >> $REPORT_FILE
grep "Failed password" /var/log/auth.log | tail -20 >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 5. 檢查最近的 sudo 使用
echo "5. 最近的 sudo 使用" >> $REPORT_FILE
echo "----------------------------" >> $REPORT_FILE
grep "sudo:" /var/log/auth.log | tail -20 >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 6. 檢查使用者帳號
echo "6. 系統使用者帳號" >> $REPORT_FILE
echo "----------------------------" >> $REPORT_FILE
echo "有登入 shell 的使用者:" >> $REPORT_FILE
grep -v "/usr/sbin/nologin\|/bin/false" /etc/passwd | cut -d: -f1 >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 7. 檢查 cron 任務
echo "7. 所有使用者的 cron 任務" >> $REPORT_FILE
echo "----------------------------" >> $REPORT_FILE
for user in $(cut -f1 -d: /etc/passwd); do
  crontab_output=$(crontab -u $user -l 2>/dev/null)
  if [ ! -z "$crontab_output" ]; then
    echo "$user 的 cron 任務:" >> $REPORT_FILE
    echo "$crontab_output" >> $REPORT_FILE
    echo "" >> $REPORT_FILE
  fi
done

# 8. 檢查敏感檔案權限
echo "8. 敏感檔案權限" >> $REPORT_FILE
echo "----------------------------" >> $REPORT_FILE
echo "SSH 金鑰:" >> $REPORT_FILE
find /home -name "id_rsa" -o -name "*.pem" -o -name "*.key" | xargs ls -la 2>/dev/null >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 9. 檢查世界可寫的目錄
echo "9. 世界可寫的目錄" >> $REPORT_FILE
echo "----------------------------" >> $REPORT_FILE
find / -type d -perm -o+w -not -path "/proc/*" -not -path "/sys/*" -not -path "/dev/*" 2>/dev/null >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 10. 檢查無擁有者的檔案
echo "10. 無擁有者的檔案" >> $REPORT_FILE
echo "----------------------------" >> $REPORT_FILE
find / -nouser -o -nogroup -not -path "/proc/*" -not -path "/sys/*" 2>/dev/null | head -20 >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 11. 檢查防火牆狀態
echo "11. 防火牆狀態" >> $REPORT_FILE
echo "----------------------------" >> $REPORT_FILE
if command -v ufw >/dev/null 2>&1; then
  ufw status >> $REPORT_FILE
elif command -v iptables >/dev/null 2>&1; then
  iptables -L -n >> $REPORT_FILE
else
  echo "未安裝防火牆或無法檢測" >> $REPORT_FILE
fi
echo "" >> $REPORT_FILE

# 12. 檢查磁碟使用情況
echo "12. 磁碟使用情況" >> $REPORT_FILE
echo "----------------------------" >> $REPORT_FILE
df -h >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 13. 檢查大型檔案
echo "13. 最大的 10 個檔案" >> $REPORT_FILE
echo "----------------------------" >> $REPORT_FILE
find / -type f -not -path "/proc/*" -not -path "/sys/*" -exec ls -lh {} \; 2>/dev/null | sort -k 5 -hr | head -10 >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 如果發現危險問題，發送電子郵件警報
if grep -q "Failed password" $REPORT_FILE || find / -perm -4000 -user root -not -path "/bin/*" -not -path "/sbin/*" -not -path "/usr/*" 2>/dev/null | grep -q .; then
  # 創建警報摘要
  SUMMARY_FILE="/tmp/security_summary.txt"
  echo "安全警報: $HOSTNAME 發現潛在安全問題" > $SUMMARY_FILE
  echo "" >> $SUMMARY_FILE
  
  if grep -q "Failed password" $REPORT_FILE; then
    echo "發現多次登入失敗嘗試" >> $SUMMARY_FILE
    grep "Failed password" $REPORT_FILE | head -5 >> $SUMMARY_FILE
    echo "" >> $SUMMARY_FILE
  fi
  
  # 發送電子郵件警報
  cat $SUMMARY_FILE | mail -s "安全警報: $HOSTNAME" $EMAIL
  echo "已發送警報電子郵件到 $EMAIL"
fi

echo "安全檢查完成，報告已儲存到 $REPORT_FILE"
```

**設定為每日自動執行：**
```bash
# 設定權限
sudo chmod +x /path/to/comprehensive_security_check.sh

# 創建 cron 任務
sudo crontab -e

# 每日凌晨 3 點執行
0 3 * * * /path/to/comprehensive_security_check.sh
```

**技術解釋：**
- `netstat -tuln`：顯示所有開放的 TCP/UDP 連接埠
- `grep "Failed password" /var/log/auth.log`：尋找登入失敗的嘗試記錄
- `find / -perm -4000`：尋找所有設定了 SUID 位的檔案，這些檔案可能有安全風險
- `find / -type d -perm -o+w`：尋找世界可寫的目錄，這些目錄可能被利用來存放惡意腳本
- `ufw status`：檢查防火牆狀態

這個腳本提供了全面的安全檢查，包括網路連接、使用者帳號、檔案權限、登入失敗嘗試等多個安全面向。定期執行這個腳本可以幫助資料工程師提前發現潛在的安全問題。

---

## 🎁 Bonus：專案實作小練習

### ✅ CPU 壓力測試 Script
```python
# cpu_stress.py
while True:
    pass
```

用來練習 top / ps / kill！

---

## 🌟 主題六：ETL 腳本實例

### 📊 完整 ETL 處理流程範例
```bash
#!/bin/bash
# etl_pipeline.sh

# 設定變數
SOURCE_DIR="/data/source"
STAGING_DIR="/data/staging"
TARGET_DIR="/data/warehouse"
LOG_FILE="etl_$(date +%F).log"
ERROR_COUNT=0

# 函數：記錄訊息
log_message() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

# 函數：錯誤處理
handle_error() {
    ERROR_COUNT=$((ERROR_COUNT + 1))
    log_message "錯誤: $1"
    
    # 發送錯誤通知
    if [ $ERROR_COUNT -eq 1 ]; then
        curl -X POST -H "Content-Type: application/json" \
             -d "{\"text\":\"ETL 錯誤: $1\"}" \
             https://hooks.slack.com/services/YOUR_WEBHOOK_URL
    fi
}

# 函數：資料提取
extract_data() {
    log_message "開始資料提取..."
    
    # 從資料來源下載檔案
    if wget -q -P $STAGING_DIR https://example.com/api/data.csv; then
        log_message "資料下載成功"
    else
        handle_error "資料下載失敗"
        return 1
    fi
    
    # 從資料庫匯出資料
    if psql -c "COPY (SELECT * FROM sales WHERE date = current_date - 1) TO '$STAGING_DIR/db_export.csv' WITH CSV HEADER"; then
        log_message "資料庫匯出成功"
    else
        handle_error "資料庫匯出失敗"
        return 1
    fi
    
    return 0
}

# 函數：資料轉換
transform_data() {
    log_message "開始資料轉換..."
    
    # 使用 awk 處理 CSV 檔案
    awk -F, 'NR>1 {sum[$1] += $2} END {for (region in sum) print region "," sum[region]}' \
        $STAGING_DIR/data.csv > $STAGING_DIR/transformed.csv
    
    if [ $? -eq 0 ]; then
        log_message "資料轉換成功"
        return 0
    else
        handle_error "資料轉換失敗"
        return 1
    fi
}

# 函數：資料載入
load_data() {
    log_message "開始資料載入..."
    
    # 移動處理好的檔案到目標目錄
    if mv $STAGING_DIR/transformed.csv $TARGET_DIR/data_$(date +%F).csv; then
        log_message "檔案移動成功"
    else
        handle_error "檔案移動失敗"
        return 1
    fi
    
    # 載入資料到資料庫
    if psql -c "\\COPY summary_table FROM '$TARGET_DIR/data_$(date +%F).csv' WITH CSV"; then
        log_message "資料載入資料庫成功"
    else
        handle_error "資料載入資料庫失敗"
        return 1
    fi
    
    return 0
}

# 主程序
main() {
    log_message "ETL 流程開始"
    
    # 建立必要的目錄
    mkdir -p $STAGING_DIR $TARGET_DIR
    
    # 執行 ETL 流程
    if extract_data && transform_data && load_data; then
        log_message "ETL 流程成功完成"
        
        # 清理暫存檔案
        rm -rf $STAGING_DIR/*
        
        # 產生成功報告
        echo "ETL 成功完成，處理時間: $(date)" > $TARGET_DIR/success_$(date +%F).txt
        
        return 0
    else
        log_message "ETL 流程失敗，錯誤數: $ERROR_COUNT"
        return 1
    fi
}

# 執行主程序
main
exit $?
```

### 🔄 結合 cron、log 分析和錯誤處理
```bash
# crontab 設定
# 0 2 * * * /path/to/etl_pipeline.sh >> /var/log/etl/cron_$(date +\%F).log 2>&1

# 錯誤監控腳本
#!/bin/bash
# monitor_etl.sh

LOG_DIR="/var/log/etl"
YESTERDAY=$(date -d "yesterday" +%F)
LOG_FILE="$LOG_DIR/cron_$YESTERDAY.log"

if grep -q "ETL 流程失敗" $LOG_FILE; then
    echo "ETL 昨日執行失敗，詳細資訊："
    grep -A 10 "錯誤:" $LOG_FILE
    
    # 發送警報
    mail -s "ETL 失敗警報" admin@example.com < $LOG_FILE
fi
```

---

## ✅ 延伸任務（Day2 Bonus）

- `for + parallel`：模擬 Spark 並行 map 處理
- `config.env`：用參數控制資料範圍
- 根據 log 成功與否自動移動檔案
- 產生 CSV / HTML 總約報表
- GitLab CI/CD 自動化執行，模擬真實情境
- 發送 Email 通知錯誤（可接 webhook）

---

## 🏁 總結：Day 2 技能樹

- ✅ 程式與資源觀察
- ✅ 自動排程 cron 任務
- ✅ 寫出流程控制 Shell script
- ✅ 分析錯誤與 log 模擬測試
- ✅ 開始打造你自己的自動化資料處理 pipeline！
- ✅ 進階監控工具與技巧
- ✅ 日誌管理與分析
- ✅ Shell Script 進階功能
- ✅ 基本安全性實踐
- ✅ 完整 ETL 腳本實例
