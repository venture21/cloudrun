from flask import Flask, render_template, request
from flask_socketio import SocketIO, emit, send
import os
from datetime import datetime

app = Flask(__name__)
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'your-secret-key-here')

socketio = SocketIO(app, cors_allowed_origins="*", async_mode='threading')

messages = []

@app.route('/')
def index():
    return render_template('index.html')

@socketio.on('connect')
def handle_connect():
    print('Client connected')
    emit('previous_messages', messages)

@socketio.on('disconnect')
def handle_disconnect():
    print('Client disconnected')

@socketio.on('message')
def handle_message(data):
    print(f'Received message: {data}')
    
    timestamp = datetime.now().strftime('%H:%M:%S')
    message_data = {
        'username': data.get('username', 'Anonymous'),
        'message': data.get('message', ''),
        'timestamp': timestamp
    }
    
    messages.append(message_data)
    
    if len(messages) > 100:
        messages.pop(0)
    
    emit('message', message_data, broadcast=True)

@socketio.on('user_typing')
def handle_typing(data):
    emit('user_typing', data, broadcast=True, include_self=False)

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    socketio.run(app, host='0.0.0.0', port=port, debug=True)