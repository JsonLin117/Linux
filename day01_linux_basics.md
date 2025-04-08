# 🐧 Linux 學習筆記：Day 1

> 本篇為第一天在 WSL (Ubuntu) Linux 系統下，針對 Data Engineer 實戰方向的基礎學習紀錄。

---

## 📌 Data Engineer 必學 / 常見指令分類總覽

### ✅ 一定會用到的指令（Daily 使用）
- `cd`, `ls`, `mkdir`, `touch`, `rm`, `cp`, `mv`：資料夾與檔案操作
- `cat`, `tail -f`, `grep`, `awk`, `sed`, `wc`：log 分析與文字處理
- `chmod`, `./script.sh`, `source`：權限與執行腳本
- `python3`, `pip`, `venv`：Python 環境與開發
- `git`, `git add`, `git commit`, `git push`：版本控制與 CI/CD 配合
- `vim`, `nano`：文字編輯器
- `curl`, `wget`：API 測試與檔案下載

### 🧪 常見使用場景會接觸到的指令
- `top`, `htop`, `df -h`, `du -sh *`：資源監控與排查爆炸狀況
- `ps aux`, `kill`, `pkill`, `time`, `watch`：系統程序管理
- `crontab`, `at`, `systemctl`：排程任務與服務啟停
- `ping`, `traceroute`, `nslookup`, `nc`：網路診斷與連線測試
- `|`, `>`, `>>`, `<`, `2>`, `2>&1`：管道與重定向

### 🧠 進階或部署環境需要懂的指令（遇到 Docker / CI / 雲端）
- `docker`, `docker-compose`, `systemctl`：容器與服務維運
- `ssh`, `scp`, `rsync`：跨主機開發與資料同步
- `tar`, `zip`, `unzip`：壓縮與封存資料
- `journalctl`, `logrotate`：伺服器 log 追蹤與管理
- `chmod`, `chown`, `umask`：權限與檔案安全控管
- `export`, `echo $PATH`, `source .bashrc`：環境變數管理

---

## ☁️ 延伸應用場景：與現代開發工具對應的 Linux 指令

### Kubernetes（K8s）
- `kubectl`：K8s CLI，操作 pod / service 等
- `watch`, `grep`, `tail -f`：監控 pod log / 狀態變化
- `journalctl`, `systemctl`：查看部署節點服務狀況（若在裸機或 VM 上）

### GitHub Actions / GitLab CI/CD
- `.sh` 腳本撰寫：搭配 `chmod +x`、`./deploy.sh`
- `env`, `printenv`：查看環境變數
- `curl`, `jq`：打 webhook / call API 解析回應

### REST / RESTful API（含 FastAPI 寫 CRUD）
- `uvicorn app:app`：啟動 FastAPI 應用
- `curl -X GET/POST`：打 API 做測試
- `netstat -tuln`, `lsof -i :8000`：確認 port 是否被佔用
- `kill`, `ps aux | grep uvicorn`：中止背景 API 程序

### gRPC
- `python -m grpc_tools.protoc`：編譯 proto 檔
- `lsof`, `ss -lntp`：監聽 port / 程序除錯

### WebSocket
- `websocat`, `wscat`（需安裝）：連線測試工具
- `netstat`, `curl`（測試傳送 header / keepalive）
- `tmux`, `screen`：背景持續觀察 WebSocket 行為

---

## ✅ 基本概念

### WSL 是什麼？
WSL（Windows Subsystem for Linux）讓我們可以在 Windows 上執行原生 Linux。這代表你可以保有 Windows 的 GUI 操作習慣，同時獲得 Linux 的開發環境優勢。

### Home 目錄
- Linux 中 `~` 或 `cd` 表示 home 目錄。
- WSL 的 home 目錄通常是 `/home/你的帳號名`，像我的是 `/home/ff_pc`

```bash
cd ~        # 回到 home
cd          # 也可以這樣寫
```

---

## ✅ 基本檔案操作指令

### 建立資料夾
```bash
mkdir my_folder            # 建立單一資料夾
mkdir -p a/{b,c,d}         # 同時建立多層結構（-p：自動建立父層）
```

### 建立檔案
```bash
touch hello.txt            # 建立空檔案
```

### 複製 / 移動 / 刪除
```bash
cp A.txt B.txt             # 複製檔案
mv A.txt B.txt             # 移動或重新命名檔案
rm A.txt                   # 刪除檔案
rm -r folder/              # 刪除資料夾（遞迴刪除）
```

### 檔案與資料夾瀏覽
```bash
ls                        # 列出目錄內容
ls -al                    # 顯示詳細資訊（含隱藏檔）
cd folder_name            # 進入資料夾
cd ..                     # 返回上層
pwd                       # 顯示目前所在路徑
```

---

## ✅ 系統監控與資源分析

### top
查看系統中目前 CPU、RAM 的使用狀況（即時刷新）
```bash
top
```
- 按 `q` 離開

### htop（需安裝）
```bash
sudo apt install htop
htop
```
- 使用方向鍵操作
- 按 `F3` 搜尋、`F9` kill、`q` 離開

### 查看磁碟與記憶體
```bash
df -h           # 查看各個磁碟掛載點的使用量
```
```bash
du -sh *        # 查看當前資料夾下的每個項目大小
```

---

## ✅ 檔案內容處理指令

### 顯示文字檔內容
```bash
cat 檔名            # 顯示整份內容
tail -f 檔名        # 即時監看 log
```

### 搜尋與過濾
```bash
grep "keyword" 檔案             # 搜尋關鍵字
grep -n --color "keyword" 檔案 # 顯示行號 & 高亮
```

### 分欄與處理文字
```bash
awk '{print $1}' 檔案          # 顯示每行的第一欄
sed 's/old/new/g' 檔案         # 將文字替換
```

### 統計
```bash
wc -l 檔案                     # 統計行數
```

---

## ✅ 網路診斷與連線指令

### 網路連線測試
```bash
ping google.com                 # 測試網路連線能力
traceroute google.com           # 追蹤封包路徑
nslookup google.com             # DNS 查詢
dig google.com                  # 詳細 DNS 查詢
```

### API 與檔案下載
```bash
curl https://api.example.com    # 發送 HTTP 請求
curl -X POST -d "data" URL      # 發送 POST 請求
wget https://example.com/file   # 下載檔案
```

### 端口連線測試
```bash
nc -zv host.com 80              # 測試特定主機端口是否開放
netstat -tuln                   # 列出所有開放的端口
lsof -i :8080                   # 查看哪個程序佔用了 8080 端口
```

---

## ✅ 文字編輯器基礎

### Vim 基本操作
```bash
vim filename.txt                # 開啟檔案
```
- 模式切換：`i` 進入編輯模式，`Esc` 返回命令模式
- 儲存退出：命令模式下 `:wq` 儲存並退出，`:q!` 不儲存強制退出
- 搜尋：命令模式下 `/關鍵字` 然後按 `n` 尋找下一個

### Nano 基本操作
```bash
nano filename.txt               # 開啟檔案
```
- 儲存：`Ctrl+O` 然後 `Enter`
- 退出：`Ctrl+X`
- 搜尋：`Ctrl+W` 輸入關鍵字

---

## ✅ 管道與重定向

### 管道：將一個指令的輸出作為另一個指令的輸入
```bash
ls -l | grep "txt"              # 只列出 txt 檔案
ps aux | grep python            # 只顯示 python 相關程序
cat log.txt | grep ERROR | wc -l # 計算錯誤數量
```

### 重定向：將輸出導向檔案
```bash
echo "Hello" > file.txt         # 覆寫檔案內容
echo "World" >> file.txt        # 附加到檔案末尾
command 2> error.log            # 將錯誤輸出導向檔案
command > output.log 2>&1       # 將標準輸出和錯誤輸出都導向檔案
```

---

## ✅ 權限與執行

### 賦予執行權限
```bash
chmod +x 檔名.sh
```

### 執行 shell script
```bash
./檔名.sh
```

---

### tree
```bash
tree -L 2           # 顯示資料夾結構，深度 2 層
tree -a             # 顯示隱藏檔
```

### 使用者身份確認 & 權限問題
```bash
whoami               # 顯示目前使用者
sudo chown -R ff_pc:ff_pc 資料夾   # 把 root 權限還給自己
```

---

## ✅ 環境變數管理

### 查看與設置環境變數
```bash
echo $PATH                      # 查看 PATH 變數
export PATH=$PATH:/new/path     # 暫時新增路徑到 PATH
env                             # 查看所有環境變數
```

### 永久設置環境變數
```bash
echo 'export PATH=$PATH:/new/path' >> ~/.bashrc  # 加入 .bashrc
source ~/.bashrc                # 重新載入 .bashrc
```

### 常用環境變數檔案
- `~/.bashrc` 或 `~/.zshrc`：使用者專屬設定
- `~/.profile`：登入時載入
- `/etc/environment`：系統全域設定

---

## ✅ 指令說明與幫助工具

### man 與 help
```bash
man ls                         # 顯示 ls 指令的完整手冊
ls --help                      # 顯示簡短的幫助信息
```

### tldr - 簡化版指令說明
`tldr` 是一個提供簡潔實用範例的指令工具，比 `man` 更容易理解。

```bash
# 安裝 tldr
sudo apt install tldr
# 或使用 npm 安裝
npm install -g tldr

# 更新 tldr 資料庫
tldr --update

# 查詢指令用法
tldr tar                       # 顯示 tar 的常用範例
tldr find                      # 顯示 find 的常用範例
tldr docker                    # 顯示 docker 的常用範例
```

與 `man` 相比，`tldr` 提供：
- 更簡潔的說明
- 實際使用的範例
- 彩色輸出，易於閱讀
- 專注於最常用的選項

---

✅ Day 1 完成！目前已能在 Linux 中：
- 建立資料夾與檔案，熟悉路徑與權限
- 開始開發專案（MCP）
- 基本使用 Git 管理專案
- 開始觀察系統資源
- 撰寫與執行 shell script
- 進行網路診斷與連線測試
- 使用文字編輯器編輯檔案
- 運用管道與重定向處理資料流
- 管理環境變數

👉 接下來 Day 2 預計學習：cron 排程、自動化 script、系統程序管理 & 進階 log 處理。