#!/bin/bash
set -e
GITHUB_USER="${1:?请提供 GitHub 用户名}"
REPO_NAME="${2:-AccountManagement}"
API_URL="${3:-http://localhost:8080/api}"
FRONTEND_DIR="$(cd "$(dirname "$0")/frontend" && pwd)"
PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "============================================"
echo "  部署配置"
echo "  GitHub: $GITHUB_USER/$REPO_NAME"
echo "  API:    $API_URL"
echo "============================================"

# 1. 写入 .env.production
echo "[1/5] 生成 .env.production ..."
cat > "$FRONTEND_DIR/.env.production" << EOF
VITE_API_BASE_URL=$API_URL
EOF

# 2. 构建
echo "[2/5] 构建前端 ..."
cd "$FRONTEND_DIR"
npm install --silent
npm run build
echo "  构建完成: $FRONTEND_DIR/dist/"

# 3. 确保 main 有提交
echo "[3/5] 同步 main 分支 ..."
cd "$PROJECT_ROOT"
git checkout main 2>/dev/null || git checkout -b main
if ! git rev-parse HEAD >/dev/null 2>&1; then
  touch .gitkeep && git add .gitkeep && git commit -m "init"
fi
git pull origin main 2>/dev/null || true

# 4. 推送 GitHub Pages
echo "[4/5] 推送到 GitHub Pages ..."
cd "$FRONTEND_DIR/dist"
git init
git checkout -b gh-pages
git add -A
git commit -m "deploy $(date '+%Y-%m-%d %H:%M')" || true
git push -f "https://github.com/${GITHUB_USER}/${REPO_NAME}.git" gh-pages:gh-pages
rm -rf .git

# 5. 完成
PAGES_URL="https://${GITHUB_USER}.github.io/${REPO_NAME}/"
echo ""
echo "============================================"
echo "  部署成功!"
echo "  前端: ${PAGES_URL}"
echo "  后端: ${API_URL}"
echo "============================================"
