FROM python:3.11-slim

WORKDIR /app

# 安装依赖
RUN pip install --no-cache-dir revChatGPT flask gunicorn

# 复制应用代码
COPY api.py /app/

# 暴露端口
EXPOSE 8000

# 启动命令
CMD ["gunicorn", "-w", "1", "-b", "0.0.0.0:8000", "api:app"]
