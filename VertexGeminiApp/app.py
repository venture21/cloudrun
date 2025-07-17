import os
from flask import Flask, request, jsonify
from flask_cors import CORS
import vertexai
from vertexai.generative_models import GenerativeModel
from datetime import datetime
import pytz

app = Flask(__name__)
CORS(app)

# Initialize Vertex AI
PROJECT_ID = os.environ.get('PROJECT_ID', 'sesac-dev-400904')
LOCATION = os.environ.get('LOCATION', 'us-central1')

vertexai.init(project=PROJECT_ID, location=LOCATION)
model = GenerativeModel("gemini-2.5-flash")

# Store chat sessions (in production, use a proper database)
chat_sessions = {}

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "healthy"}), 200

@app.route('/chat', methods=['POST'])
def chat():
    try:
        data = request.json
        user_message = data.get('message')
        session_id = data.get('session_id', 'default')
        
        if not user_message:
            return jsonify({"error": "Message is required"}), 400
        
        # Get or create chat session
        if session_id not in chat_sessions:
            chat_sessions[session_id] = model.start_chat()
        
        chat = chat_sessions[session_id]
        
        # Get current time in KST
        kst = pytz.timezone('Asia/Seoul')
        current_time = datetime.now(kst).strftime('%Y-%m-%d %H:%M:%S')
        
        # Send message to Gemini
        response = chat.send_message(
            user_message,
            generation_config={
                "max_output_tokens": 8192,
                "temperature": 0.9,
                "top_p": 1.0,
                "top_k": 32
            }
        )
        
        return jsonify({
            "response": response.text,
            "timestamp": current_time,
            "session_id": session_id
        }), 200
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/chat/reset', methods=['POST'])
def reset_chat():
    try:
        data = request.json
        session_id = data.get('session_id', 'default')
        
        if session_id in chat_sessions:
            del chat_sessions[session_id]
        
        return jsonify({"message": "Chat session reset successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    # For local development only
    debug_mode = os.environ.get('FLASK_ENV') == 'development'
    app.run(host='0.0.0.0', port=port, debug=debug_mode)
