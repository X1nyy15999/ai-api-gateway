# AI API Gateway

一键部署 ChatGPT 和 Claude 网页版转 API 服务，支持 NewAPI 等中转平台对接。

## 功能特点

- ✅ **ChatGPT 网页版转 API** - 支持 Access Token 和账号密码登录
- ✅ **Claude 网页版转 API** - 支持 Session Token
- ✅ **OpenAI 标准格式** - 兼容所有 OpenAI 客户端
- ✅ **Docker 一键部署** - 无需复杂配置
- ✅ **支持 NewAPI 等中转** - 轻松接入现有系统

## 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/yourusername/ai-api-gateway.git
cd ai-api-gateway
```

### 2. 配置环境变量

```bash
cp .env.example .env
vim .env
```

编辑 `.env` 文件：

```env
# ChatGPT 配置 (二选一)
# 方式1: Access Token (推荐)
CHATGPT_ACCESS_TOKEN=your_access_token_here

# 方式2: 账号密码
# CHATGPT_EMAIL=your_email@example.com
# CHATGPT_PASSWORD=your_password

# Claude 配置
CLAUDE_SESSION_KEY=sk-ant-sid01-xxxxx
CLAUDE_API_KEY=your_custom_api_key

# 端口配置
CHATGPT_PORT=3040
CLAUDE_PORT=8080
```

### 3. 一键部署

```bash
chmod +x deploy.sh
./deploy.sh
```

或直接使用 Docker Compose：

```bash
docker-compose up -d
```

## 获取凭证

### ChatGPT Access Token

1. 访问 https://chat.openai.com 登录
2. 访问 https://chat.openai.com/api/auth/session
3. 复制 `accessToken` 字段的值

### Claude Session Key

1. 访问 https://claude.ai 登录
2. 按 F12 → Application → Cookies
3. 找到 `sessionKey` (格式: `sk-ant-sid01-...`)

## API 使用

### ChatGPT

```bash
curl http://localhost:3040/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer anything" \
  -d '{
    "model": "gpt-4",
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```

### Claude

```bash
curl http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_custom_api_key" \
  -d '{
    "model": "claude-3-7-sonnet-20250219",
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```

## NewAPI 配置

| 渠道 | 类型 | 地址 | 密钥 |
|------|------|------|------|
| ChatGPT | OpenAI | `http://服务器IP:3040/v1` | `sk-anything` |
| Claude | OpenAI | `http://服务器IP:8080/v1` | `your_custom_api_key` |

## 项目结构

```
ai-api-gateway/
├── docker-compose.yml      # Docker 编排
├── deploy.sh              # 一键部署脚本
├── .env.example           # 环境变量示例
├── chatgpt/               # ChatGPT 服务
│   ├── Dockerfile
│   └── api.py
├── claude/                # Claude 服务
│   └── (使用 claude2api)
└── README.md
```

## 依赖项目

- [acheong08/ChatGPT](https://github.com/acheong08/ChatGPT) - ChatGPT 逆向工程
- [yushangxiao/claude2api](https://github.com/yushangxiao/claude2api) - Claude 转 API

## 许可证

MIT
