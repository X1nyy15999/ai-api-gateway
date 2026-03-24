#!/bin/bash
# AI API Gateway 一键部署脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  AI API Gateway 一键部署${NC}"
echo -e "${GREEN}  ChatGPT + Claude 网页转 API${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker 未安装${NC}"
    echo "请先安装 Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose 未安装${NC}"
    echo "请先安装 Docker Compose"
    exit 1
fi

echo -e "${GREEN}✓ Docker 环境检查通过${NC}"
echo ""

# 检查配置文件
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠ 未找到 .env 配置文件${NC}"
    echo "正在从 .env.example 创建..."
    cp .env.example .env
    echo -e "${YELLOW}请编辑 .env 文件配置您的凭证，然后重新运行此脚本${NC}"
    echo ""
    echo "获取凭证方法:"
    echo "1. ChatGPT Access Token: https://chat.openai.com/api/auth/session"
    echo "2. Claude Session Key: https://claude.ai → F12 → Application → Cookies"
    echo ""
    exit 1
fi

# 检查必要的环境变量
source .env

if [ -z "$CHATGPT_ACCESS_TOKEN" ] && ([ -z "$CHATGPT_EMAIL" ] || [ -z "$CHATGPT_PASSWORD" ]); then
    echo -e "${RED}❌ 请配置 ChatGPT 凭证${NC}"
    echo "编辑 .env 文件，设置 CHATGPT_ACCESS_TOKEN 或 CHATGPT_EMAIL + CHATGPT_PASSWORD"
    exit 1
fi

if [ -z "$CLAUDE_SESSION_KEY" ]; then
    echo -e "${RED}❌ 请配置 CLAUDE_SESSION_KEY${NC}"
    echo "编辑 .env 文件，设置 CLAUDE_SESSION_KEY"
    exit 1
fi

echo -e "${GREEN}✓ 配置文件检查通过${NC}"
echo ""

# 构建和启动
echo -e "${YELLOW}→ 正在构建和启动服务...${NC}"
docker-compose up -d --build

echo ""
echo -e "${GREEN}✓ 服务已启动${NC}"
echo ""

# 等待服务启动
echo -e "${YELLOW}→ 等待服务初始化...${NC}"
sleep 5

# 健康检查
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  健康检查${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

CHATGPT_PORT=${CHATGPT_PORT:-3040}
CLAUDE_PORT=${CLAUDE_PORT:-8080}

# 检查 ChatGPT
if curl -s http://localhost:$CHATGPT_PORT/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ ChatGPT API 正常${NC}"
else
    echo -e "${YELLOW}⚠ ChatGPT API 可能还在启动中${NC}"
    echo "  请稍后检查: docker logs -f chatgpt-api"
fi

# 检查 Claude
if curl -s http://localhost:$CLAUDE_PORT/v1/models > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Claude API 正常${NC}"
else
    echo -e "${YELLOW}⚠ Claude API 可能还在启动中${NC}"
    echo "  请稍后检查: docker logs -f claude-api"
fi

# 显示信息
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  部署完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "📌 ${YELLOW}ChatGPT API:${NC}"
echo "   地址: http://服务器IP:$CHATGPT_PORT/v1"
echo "   模型: gpt-4, gpt-3.5"
echo "   密钥: 任意值"
echo ""
echo -e "📌 ${YELLOW}Claude API:${NC}"
echo "   地址: http://服务器IP:$CLAUDE_PORT/v1"
echo "   模型: claude-3-7-sonnet-20250219"
echo "   密钥: ${CLAUDE_API_KEY:-claude-api-key-123}"
echo ""
echo -e "📌 ${YELLOW}NewAPI 配置:${NC}"
echo ""
echo "   【ChatGPT 渠道】"
echo "   类型: OpenAI"
echo "   地址: http://服务器IP:$CHATGPT_PORT/v1"
echo "   密钥: sk-anything"
echo ""
echo "   【Claude 渠道】"
echo "   类型: OpenAI"
echo "   地址: http://服务器IP:$CLAUDE_PORT/v1"
echo "   密钥: ${CLAUDE_API_KEY:-claude-api-key-123}"
echo ""
echo -e "📋 ${YELLOW}常用命令:${NC}"
echo "   查看日志: docker-compose logs -f"
echo "   停止服务: docker-compose down"
echo "   重启服务: docker-compose restart"
echo "   更新镜像: docker-compose pull && docker-compose up -d"
echo ""
