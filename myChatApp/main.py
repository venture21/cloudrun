
from flask import Flask, render_template, request, jsonify

app = Flask(__name__)

messages = []

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/send', methods=['POST'])
def send():
    message = request.json.get('message')
    if message:
        messages.append(message)
    return jsonify({'status': 'OK'})

@app.route('/messages')
def get_messages():
    return jsonify(messages)

if __name__ == '__main__':
    app.run(debug=True, port=8080)
