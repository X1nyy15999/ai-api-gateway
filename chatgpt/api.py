#!/usr/bin/env python3
"""
ChatGPT Web to API
基于 acheong08/ChatGPT 的逆向工程实现
"""

import os
import json
from flask import Flask, request, jsonify, Response
from revChatGPT.V1 import Chatbot

app = Flask(__name__)

# 初始化 ChatGPT
def init_chatbot():
    config = {}
    
    # 优先使用 Access Token
    access_token = os.getenv('CHATGPT_ACCESS_TOKEN')
    if access_token:
        config['access_token'] = access_token
    else:
        # 使用账号密码
        email = os.getenv('CHATGPT_EMAIL')
        password = os.getenv('CHATGPT_PASSWORD')
        if email and password:
            config['email'] = email
            config['password'] = password
        else:
            raise ValueError("请配置 CHATGPT_ACCESS_TOKEN 或 CHATGPT_EMAIL + CHATGPT_PASSWORD")
    
    # 可选配置
    model = os.getenv('CHATGPT_MODEL', 'gpt-4')
    config['model'] = model
    config['disable_history'] = False
    
    return Chatbot(config=config)

# 全局 Chatbot 实例
chatbot = init_chatbot()


@app.route('/v1/chat/completions', methods=['POST'])
def chat_completions():
    """OpenAI 兼容的聊天接口"""
    try:
        data = request.json
        messages = data.get('messages', [])
        stream = data.get('stream', False)
        model = data.get('model', 'gpt-4')
        
        # 获取最后一条用户消息
        prompt = ""
        for msg in reversed(messages):
            if msg.get('role') == 'user':
                prompt = msg.get('content', '')
                break
        
        if not prompt:
            return jsonify({'error': 'No user message found'}), 400
        
        # 非流式响应
        if not stream:
            response_text = ""
            for data in chatbot.ask(prompt, model=model):
                response_text = data["message"]
            
            return jsonify({
                'id': 'chatcmpl-web',
                'object': 'chat.completion',
                'created': 1700000000,
                'model': model,
                'choices': [{
                    'index': 0,
                    'message': {
                        'role': 'assistant',
                        'content': response_text
                    },
                    'finish_reason': 'stop'
                }],
                'usage': {
                    'prompt_tokens': len(prompt.split()),
                    'completion_tokens': len(response_text.split()),
                    'total_tokens': len(prompt.split()) + len(response_text.split())
                }
            })
        
        # 流式响应
        def generate():
            prev_text = ""
            for data in chatbot.ask(prompt, model=model):
                message = data["message"]
                delta = message[len(prev_text):]
                prev_text = message
                
                if delta:
                    yield f'data: {json.dumps({"choices": [{"delta": {"content": delta}}]})}\n\n'
            
            yield 'data: [DONE]\n\n'
        
        return Response(generate(), mimetype='text/plain')
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/v1/models', methods=['GET'])
def list_models():
    """获取可用模型列表"""
    return jsonify({
        'object': 'list',
        'data': [
            {'id': 'gpt-4o', 'object': 'model'},
            {'id': 'gpt-4o-mini', 'object': 'model'},
            {'id': 'gpt-4', 'object': 'model'},
            {'id': 'gpt-4-turbo', 'object': 'model'},
            {'id': 'gpt-3.5-turbo', 'object': 'model'},
        ]
    })


@app.route('/health', methods=['GET'])
def health():
    """健康检查"""
    return jsonify({'status': 'ok'})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=False)
