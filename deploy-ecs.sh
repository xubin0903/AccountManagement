#!/bin/bash
# ECS 一键部署脚本
# 使用: ./deploy-ecs.sh
set -e

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_ROOT"

echo "============================================"
echo "  记账系统 ECS 部署"
echo "============================================"

# 1. 初始化数据库（仅首次需要）
echo ""
echo "[1/4] 初始化数据库 ..."
if mysql -u root -p123456 -e "USE account_management" 2>/dev/null; then
  echo "  数据库已存在, 跳过建库"
else
  echo "  创建数据库和表 ..."
  mysql -u root -p123456 < sql/init-mysql.sql
  echo "  数据库初始化完成"
fi

# 2. 构建前端
echo ""
echo "[2/4] 构建前端 ..."
cd "$PROJECT_ROOT/frontend"
npm install --silent 2>/dev/null || npm install
npx vite build --mode ecs
echo "  前端构建完成 → frontend/dist/"

# 3. 构建并启动容器
echo ""
echo "[3/4] 启动 Docker 容器 ..."
cd "$PROJECT_ROOT"
docker compose down 2>/dev/null || true
docker compose up -d --build

# 4. 等待启动
echo ""
echo "[4/4] 等待服务启动 ..."
sleep 8
if curl -s http://localhost:8080/users > /dev/null 2>&1; then
  echo "  ✓ 后端启动成功"
else
  echo "  ⚠ 后端可能还在启动中, 稍后请检查: docker compose logs backend"
fi

echo ""
echo "============================================"
echo "  部署完成!"
echo "  访问地址: http://$(curl -s ifconfig.me 2>/dev/null || echo '119.23.54.212')"
echo "  查看日志: docker compose logs -f"
echo "============================================"
