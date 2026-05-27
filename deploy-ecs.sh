#!/bin/bash
# ECS 一键部署脚本
# 使用: ./deploy-ecs.sh
set -e

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_ROOT"

echo "============================================"
echo "  记账系统 ECS 部署"
echo "============================================"

# 1. 检查环境
echo ""
echo "[1/5] 检查环境 ..."
if ! command -v java &>/dev/null; then
  echo "  安装 JDK 17 ..."
  if command -v apt &>/dev/null; then
    apt update -qq && apt install -y -qq openjdk-17-jdk
  elif command -v yum &>/dev/null; then
    yum install -y -q java-17-openjdk-devel
  else
    echo "  错误: 无法自动安装 JDK, 请手动安装 JDK 17"
    exit 1
  fi
fi
if ! command -v mvn &>/dev/null; then
  echo "  安装 Maven ..."
  if command -v apt &>/dev/null; then
    apt install -y -qq maven
  elif command -v yum &>/dev/null; then
    yum install -y -q maven
  else
    echo "  错误: 无法自动安装 Maven"
    exit 1
  fi
fi
echo "  ✓ JDK $(java -version 2>&1 | head -1)"
echo "  ✓ Maven $(mvn -version 2>&1 | head -1)"

# 2. 初始化数据库
echo ""
echo "[2/5] 初始化数据库 ..."
if mysql -u root -p123456 -e "USE account_management" 2>/dev/null; then
  echo "  数据库已存在, 跳过建库"
else
  echo "  创建数据库和表 ..."
  mysql -u root -p123456 < sql/init-mysql.sql
  echo "  ✓ 数据库初始化完成"
fi

# 3. 构建前端
echo ""
echo "[3/5] 构建前端 ..."
cd "$PROJECT_ROOT/frontend"
npm install --silent 2>/dev/null || npm install
npx vite build --mode ecs
echo "  ✓ 前端构建完成 → frontend/dist/"

# 4. 编译后端 (主机上编译, 避免 Docker 网络问题)
echo ""
echo "[4/5] 编译后端 ..."
cd "$PROJECT_ROOT/backend"
mvn package -DskipTests -q
echo "  ✓ 后端编译完成 → backend/target/"

# 5. 启动容器
echo ""
echo "[5/5] 启动 Docker 容器 ..."
cd "$PROJECT_ROOT"
docker compose down 2>/dev/null || true
docker compose up -d --build

# 等待启动
echo ""
sleep 6
if curl -s http://localhost:8080/users > /dev/null 2>&1; then
  echo "  ✓ 后端启动成功"
else
  echo "  ⚠ 后端可能还在启动, 稍后检查: docker compose logs backend"
fi

echo ""
echo "============================================"
echo "  部署完成!"
echo "  访问: http://$(curl -s ifconfig.me 2>/dev/null || echo '119.23.54.212')"
echo "  日志: docker compose logs -f"
echo "============================================"
