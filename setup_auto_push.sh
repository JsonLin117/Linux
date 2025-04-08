#!/bin/bash

# 設置自動推送腳本
echo "#!/bin/sh
# 自動推送到 GitHub 倉庫的 post-commit hook

# 獲取當前分支名稱
BRANCH=\$(git rev-parse --abbrev-ref HEAD)

echo \"正在自動推送到 GitHub...\"
git push github \$BRANCH

exit 0" > .git/hooks/post-commit

# 設置執行權限
chmod +x .git/hooks/post-commit

echo "自動推送 hook 已設置完成！"
echo "現在每次提交後，代碼將自動推送到 GitHub 倉庫。"
