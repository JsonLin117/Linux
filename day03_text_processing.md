# 🧠 Linux 大神之路 Day 3: 文字處理指令 grep / awk / sed / wc

## ✨ 主題一: 快速搜尋 grep

Data Engineer 常要處理流汗不已的 log、資料清潔、錯誤觸發。

### ▶️ 常見應用情境
- 搜尋 log 中的 ERROR
- 找出指定節點或時間節錄
- 推謀: 處理 AWS CloudWatch 匯出或 Spark log

### ⚖️ 技術解釋
- `grep` = **Global Regular Expression Print**，用來搜尋文件中含有指定 pattern 的行
- `-i` = **ignore-case**，不分大小寫
- `-v` = **invert-match**，反向篩選，排除 pattern
- `-A 2 -B 2` = **after/before context**，顯示 match 前後 2 行
- `-r` = **recursive**，遞迴搜尋內部所有文件

### 🌿 使用範例
```bash
grep "ERROR" pipeline.log            # 找出含 ERROR 的行
grep -i "error" pipeline.log         # 不分大小寫
grep -v "DEBUG" pipeline.log        # 排除 DEBUG 的行
grep -A 2 -B 2 "FAIL" result.log     # 列出 FAIL 前後 2 行
grep -r "spark" /var/log            # 遞迴搜尋 spark 關鍵字
```

---

## ✨ 主題二: 框約式處理 awk

`awk` = Alfred Aho, Peter Weinberger, Brian Kernighan 名字首字組成。是一個很強的 pattern scanning & processing 工具

### ▶️ 常見應用情境
- 算各地區銷售總額
- 算各樣 log 程度狀態分佈
- 從 CSV 中抓特定欄來畫圖

### ⚖️ 技術解釋
- `awk` 以行為單位，對列 (欄位) 進行進一步處理
- `$1`, `$2`, ... 代表第 N 欄
- `-F` = **field separator**，指定欄位分隔符

### 🌿 使用範例
```bash
awk '{print $1}' result.txt                   # 列出第一欄
awk -F ',' '{print $2, $5}' data.csv          # 以 ',' 為分割
awk '$3 > 1000 {print $1, $3}' report.txt     # 第三欄 > 1000
awk '{sum += $4} END {print sum}' sales.csv   # 第四欄加結
awk '{arr[$2]++} END {for (k in arr) print k, arr[k]}' file.txt  # 第二欄 groupby 
```

---

## ✨ 主題三: 正則對換 sed

`sed` = **stream editor**，用於處理流式輸入中的文字串修改

### ▶️ 常見應用情境
- 批次改正 csv/tsv 格式
- 清除未用於處理記錄
- 進行字串縮小 / 字首大小轉換

### ⚖️ 技術解釋
- `s/old/new/` = **substitute**，取代
- `/pattern/d` = **delete**，刪除匹配行
- `-n` = **no print**，不自動 print，配合 `p` 指定列印

### 🌿 使用範例
```bash
sed 's/foo/bar/' config.txt           # 只換第一個
sed 's/foo/bar/g' config.txt          # 全行取代 foo
sed '/# TODO/d' script.sh             # 刪掉 TODO 批評
sed -n '10,20p' app.log               # 列出第 10~20 行
```

---

## ✨ 主題四: 快速統計 wc

很好用的簡易計數工具，能接 grep ，看幾個键詞、行數、語幣。

### ⚖️ 技術解釋
- `wc` = **word count**
- `-l` = **line count**，行數
- `-w` = **word count**，單詞數
- `-c` = **character count**，字元數 / bytes

### 🌿 使用範例
```bash
wc -l app.log                     # 計算 app.log 有多少行
wc -w README.md                   # 單詞數
wc -c data.csv                    # 字元 (bytes)
```

---

## 🏋️‍♂️ 實戰情境: 分析 ETL 錯誤 log

### 情境: ETL DAG 失敗，需要抓出錯誤與命令速度算方案

```bash
# 找錯誤 + 幾次
grep -c "ERROR" etl.log

# 列出錯誤節點
grep "ERROR" etl.log | awk '{print $1, $2, $6}'

# 最後 10 次錯誤
grep "ERROR" etl.log | tail -10

# 錯誤分時分佈
grep "ERROR" etl.log | awk '{print substr($2,1,13)}' | sort | uniq -c
```

## 🔍 Data Engineer 進階應用場景

### 日誌解析與異常檢測

```bash
# 提取特定時間範圍內的錯誤
sed -n '/2023-04-01 10:00:00/,/2023-04-01 11:00:00/p' app.log | grep "ERROR"

# 分析 Spark 執行計劃中的 Stage 耗時
grep "Stage" spark.log | awk '{print $1, $4, $NF}' | sort -k3 -nr | head -10

# 監控特定任務的記憶體使用情況
grep "Memory usage" app.log | awk '{print $1, $2, $(NF-1), $NF}' | tail -100 > memory_trend.txt
```

### 數據清洗與轉換

```bash
# CSV 文件列轉換（例如日期格式標準化）
awk -F, '{gsub(/(\d{2})\/(\d{2})\/(\d{4})/, "\\3-\\1-\\2", $3); print}' data.csv > cleaned_data.csv

# 移除 CSV 中的引號和空格
sed 's/"//g' data.csv | sed 's/^ *//g; s/ *$//g' > clean_data.csv

# 合併多個日誌文件並提取關鍵信息
find /var/log/app/ -name "*.log" -type f -exec grep "Transaction" {} \; | awk '{print $1, $2, $9, $12}' > transactions_summary.txt
```

### 性能分析

```bash
# 提取 API 響應時間並計算平均值、最大值和分位數
grep "API response time" app.log | awk '{sum+=$NF; count++; arr[NR]=$NF} END {print "Avg:", sum/count, "Max:", arr[int(count*0.95)], "95th:", arr[int(count*0.95)], "99th:", arr[int(count*0.99)]}'

# 分析查詢執行時間分佈
grep "Query completed" db.log | awk '{print $7}' | sort -n | awk '
BEGIN {count=0}
{
  sum+=$1; count++; data[count]=$1
}
END {
  print "Min:", data[1]
  print "Max:", data[count]
  print "Avg:", sum/count
  print "Median:", data[int(count/2)]
  print "90th:", data[int(count*0.9)]
  print "95th:", data[int(count*0.95)]
  print "99th:", data[int(count*0.99)]
}'
```

### 數據質量檢查

```bash
# 檢查 CSV 文件列數是否一致
awk -F, '{print NF}' data.csv | sort | uniq -c

# 檢查數據中的 NULL 值或空字段
awk -F, '{for(i=1;i<=NF;i++) if($i=="NULL" || $i=="") null_count[i]++} END {for(i in null_count) print "Column", i, "has", null_count[i], "NULL values"}' data.csv

# 檢查數值列的範圍和分佈
awk -F, '{if(NR>1) {sum+=$3; count++; if($3>max) max=$3; if($3<min || min=="") min=$3}} END {print "Min:", min, "Max:", max, "Avg:", sum/count}' data.csv
```

### ETL 流程監控與自動化

```bash
# 監控 ETL 作業完成情況並發送通知
grep "Job completed" etl.log | awk '{
  if($NF=="SUCCESS") success++; 
  else if($NF=="FAILED") failed++
} END {
  print "Success:", success, "Failed:", failed
  if(failed>0) exit 1
}'

# 如果上一個命令返回非零，發送警報
if [ $? -ne 0 ]; then
  echo "ETL jobs failed, check logs" | mail -s "ETL Alert" data-team@example.com
fi

# 自動生成每日 ETL 報告
{
  echo "=== ETL Daily Report $(date +%F) ==="
  echo "Jobs executed: $(grep "Job started" etl.log | wc -l)"
  echo "Success rate: $(grep "Job completed" etl.log | grep "SUCCESS" | wc -l) / $(grep "Job completed" etl.log | wc -l)"
  echo "Average runtime: $(grep "Runtime" etl.log | awk '{sum+=$NF; count++} END {print sum/count " seconds"}')" 
  echo "Slowest job: $(grep "Runtime" etl.log | sort -k3 -nr | head -1)"
  echo "Data processed: $(grep "Records processed" etl.log | awk '{sum+=$NF} END {print sum " records"}')" 
} > etl_report_$(date +%F).txt
```

### 大數據平台特定場景

```bash
# 分析 Hadoop/HDFS 空間使用情況
hdfs dfs -du -h /data | sort -hr | head -10 | awk '{print $1, $2}'

# 提取 Spark 應用程序的資源使用情況
grep "executor" spark.log | awk '/memory|cores/ {print $1, $2, $(NF-1), $NF}'

# 監控 Kafka 消費延遲
grep "consumer lag" kafka.log | awk '{print $1, $2, $8}' | sort -k3 -nr | head
```

---

## ✨ 主題五: 組合應用 & 加值實戰

### 情境: 找出查詢錯誤 + 平均算結

```bash
# 找出最多錯誤來源 IP
awk '$9 ~ /500/' access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head

# 算各種 HTTP status code 分佈
awk '{print $9}' access.log | sort | uniq -c | sort -rn

# 將 response time > 3s 的項目列出
awk '$10 > 3000 {print $7, $10}' access.log | sort -nk2 | tail -5
```

---

## ⭐ Day 3 技能矩陣

| 技術 | 能力 |
|--------|------|
| `grep` | 關鍵字/錯誤搜尋  |
| `awk`  | 欄位算結/分群統計 |
| `sed`  | 文字批次變更 |
| `wc`   | 計數 (行數/字元/詞數) |

---

## ✅ 延伸任務（Day3 Bonus）

1. 做出一個 CSV 分析對照表
2. 自動把 ETL 錯誤 grep 出來加上時間
3. 使用 awk + sed 做成 summary report
4. 組合 grep + awk + sort 打造不輸 BI 的 CLI 觀測光樹

---

## 🧪 實際練習範例

在 `data/` 目錄中有三個模擬資料檔案可供練習：

1. `sales_data.csv` - 銷售資料
2. `server_logs.txt` - 伺服器日誌
3. `access_log.txt` - 網站訪問日誌

### 練習一：處理銷售資料 (sales_data.csv)

```bash
# 檢視資料結構
head -1 data/sales_data.csv
# 輸出: region,date,product,quantity,price,total
```

**命令解釋：**
- `head`: 顯示文件開頭部分
- `-1`: 只顯示第一行
- `data/sales_data.csv`: 目標文件路徑

```bash
# 計算各區域銷售總額
awk -F, 'NR>1 {sum[$1]+=$6} END {for (region in sum) print region, sum[region]}' data/sales_data.csv
# 輸出結果會顯示每個區域的總銷售額
```

**命令解釋：**
- `awk`: 文本處理工具
- `-F,`: 設置欄位分隔符為逗號
- `NR>1`: Number of Record > 1，跳過第一行（標題行）
- `{sum[$1]+=$6}`: 對每一行執行的操作，`$1`是第一列(區域)，`$6`是第六列(總額)，將每個區域的銷售額累加到`sum`數組中
- `END {...}`: 在處理完所有行後執行的代碼塊
- `for (region in sum)`: 遍歷`sum`數組中的所有鍵(區域)
- `print region, sum[region]`: 打印區域名和對應的總銷售額

```bash
# 查找銷售額超過100000的記錄
awk -F, '$6 > 100000 {print $1, $3, $6}' data/sales_data.csv
# 輸出會顯示高銷售額的區域、產品和金額
```

**命令解釋：**
- `-F,`: 設置欄位分隔符為逗號
- `$6 > 100000`: 條件表達式，只處理第六列(總額)大於100000的行
- `{print $1, $3, $6}`: 打印第一列(區域)、第三列(產品)和第六列(總額)

```bash
# 計算每種產品的總銷售量
awk -F, 'NR>1 {qty[$3]+=$4} END {for (product in qty) print product, qty[product]}' data/sales_data.csv
# 輸出會顯示每種產品的總銷售數量
```

**命令解釋：**
- `NR>1`: 跳過第一行
- `{qty[$3]+=$4}`: 將每種產品($3)的銷售量($4)累加到`qty`數組中
- `END {...}`: 處理完所有行後執行
- `for (product in qty)`: 遍歷所有產品
- `print product, qty[product]`: 打印產品名和對應的總銷售量

### 練習二：分析伺服器日誌 (server_logs.txt)

```bash
# 統計各日誌級別的數量
awk '{print $3}' data/server_logs.txt | sort | uniq -c
# 輸出會顯示 INFO、DEBUG、ERROR、WARN 等級別的數量
```

**命令解釋：**
- `{print $3}`: 打印每行的第三列(日誌級別)
- `|`: 管道符，將前一個命令的輸出作為後一個命令的輸入
- `sort`: 對輸出進行排序
- `uniq -c`: 去除重複行並計數，`-c`表示顯示計數

```bash
# 提取所有錯誤日誌
awk '$3 == "ERROR" {print $1, $2, $4, $5, $6, $7, $8, $9}' data/server_logs.txt
# 輸出會顯示所有錯誤日誌的詳細信息
```

**命令解釋：**
- `$3 == "ERROR"`: 條件表達式，只處理第三列等於"ERROR"的行
- `{print $1, $2, $4, $5, $6, $7, $8, $9}`: 打印指定列(日期、時間和錯誤詳情)

```bash
# 計算平均記憶體使用量
awk '/Memory usage/ {sum += $5; count++} END {print "Average memory usage:", sum/count "GB"}' data/server_logs.txt
# 輸出會顯示平均記憶體使用量
```

**命令解釋：**
- `/Memory usage/`: 模式匹配，只處理包含"Memory usage"的行
- `{sum += $5; count++}`: 累加第五列(內存使用量)並計數
- `END {...}`: 處理完所有行後執行
- `print "Average memory usage:", sum/count "GB"`: 打印平均內存使用量

```bash
# 按小時統計日誌數量
awk '{split($2,t,":"); count[substr($1,1,13) "-" t[1]]++} END {for (hour in count) print hour, count[hour]}' data/server_logs.txt | sort
# 輸出會顯示每小時的日誌數量
```

**命令解釋：**
- `split($2,t,":")`: 將第二列(時間)按冒號分割，存入數組`t`
- `count[substr($1,1,13) "-" t[1]]++`: 將日期($1)的前13個字符(年月日)和小時(t[1])組合作為鍵，對應的值加1
- `END {...}`: 處理完所有行後執行
- `for (hour in count)`: 遍歷所有小時
- `print hour, count[hour]`: 打印小時和對應的日誌數量
- `| sort`: 對結果進行排序

### 練習三：分析網站訪問日誌 (access_log.txt)

```bash
# 統計各 HTTP 狀態碼的數量
awk '{print $9}' data/access_log.txt | sort | uniq -c
# 輸出會顯示各狀態碼（如 200、404、500 等）的數量
```

**命令解釋：**
- `{print $9}`: 打印第九列(HTTP狀態碼)
- `| sort`: 對輸出進行排序
- `| uniq -c`: 去除重複行並計數

```bash
# 找出響應時間超過 1000ms 的請求
awk '$NF > 1000 {print $1, $7, $NF}' data/access_log.txt
# 輸出會顯示響應時間較長的請求的 IP、URL 和響應時間
```

**命令解釋：**
- `$NF`: 表示最後一列(響應時間)，NF = Number of Fields
- `$NF > 1000`: 條件表達式，只處理響應時間大於1000ms的行
- `{print $1, $7, $NF}`: 打印第一列(IP)、第七列(URL)和最後一列(響應時間)

```bash
# 計算每個 IP 的請求次數
awk '{count[$1]++} END {for (ip in count) print ip, count[ip]}' data/access_log.txt
# 輸出會顯示每個 IP 地址的請求次數
```

**命令解釋：**
- `{count[$1]++}`: 將每個 IP($1)的計數加1
- `END {...}`: 處理完所有行後執行
- `for (ip in count)`: 遍歷所有IP
- `print ip, count[ip]`: 打印IP和對應的請求次數

```bash
# 分析訪問最多的 URL
awk '{urls[$7]++} END {for (url in urls) print urls[url], url}' data/access_log.txt | sort -nr | head -5
# 輸出會顯示訪問量最大的 5 個 URL
```

**命令解釋：**
- `{urls[$7]++}`: 將每個 URL($7)的計數加1
- `END {...}`: 處理完所有行後執行
- `for (url in urls)`: 遍歷所有URL
- `print urls[url], url`: 打印訪問次數和URL(注意順序，先打印次數便於排序)
- `| sort -nr`: 對結果進行數字逆序排序，`-n`表示按數字排序，`-r`表示逆序
- `| head -5`: 只顯示前5行結果

### 綜合練習：多命令組合

```bash
# 生成每小時錯誤率報告
awk '{
  total[$1]++;
  if ($9 >= 400) errors[$1]++
} END {
  print "Hour,Total,Errors,ErrorRate";
  for (hour in total) {
    if (!errors[hour]) errors[hour]=0;
    printf "%s,%d,%d,%.2f%%\n", hour, total[hour], errors[hour], (errors[hour]/total[hour])*100
  }
}' data/access_log.txt | sort > error_rate_report.csv
```

**命令解釋：**
- `total[$1]++`: 將每個 IP 的請求總數加1
- `if ($9 >= 400) errors[$1]++`: 如果狀態碼大於等於400，將該 IP 的錯誤數加1
- `END {...}`: 處理完所有行後執行
- `print "Hour,Total,Errors,ErrorRate"`: 打印 CSV 標題行
- `if (!errors[hour]) errors[hour]=0`: 如果某小時沒有錯誤，將錯誤數設為0
- `printf "%s,%d,%d,%.2f%%\n"`: 格式化輸出，`%s`為字符串，`%d`為整數，`%.2f%%`為帶兩位小數的百分比
- `| sort > error_rate_report.csv`: 排序並將結果寫入 CSV 文件

```bash
# 找出並分析慢查詢
grep "Query executed" data/server_logs.txt | \
  sed -E 's/.*in ([0-9]+)ms: (.*)/\1 \2/' | \
  sort -nr | head -5
# 輸出會顯示最慢的 5 個查詢及其執行時間
```

**命令解釋：**
- `grep "Query executed"`: 找出包含"Query executed"的行
- `\`: 行續符，表示命令在下一行繼續
- `sed -E 's/.*in ([0-9]+)ms: (.*)/\1 \2/'`: 使用擴展正則表達式提取執行時間和查詢內容
  - `-E`: 啟用擴展正則表達式
  - `.*in ([0-9]+)ms: (.*)`: 匹配模式，捕捉數字和查詢內容
  - `\1 \2`: 替換為捕捉的內容，時間和查詢
- `sort -nr`: 按數字逆序排序，將最大的數字（最慢的查詢）放在前面
- `head -5`: 只顯示前5行結果

這些練習範例展示了如何使用 Linux 文字處理工具分析不同類型的資料，從銷售數據到伺服器日誌再到網站訪問記錄。通過組合使用 grep、awk、sed 和其他命令，你可以執行複雜的資料分析任務，而無需依賴專門的分析工具。

---

