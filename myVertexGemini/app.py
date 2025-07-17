from flask import Flask, render_template, request, jsonify
import vertexai
from vertexai.generative_models import GenerativeModel

app = Flask(__name__)

# Initialize Vertex AI
# TODO: Replace with your actual project ID and location.
PROJECT_ID = "sesac-dev-400904"
LOCATION = "us-central1"
vertexai.init(project=PROJECT_ID, location=LOCATION)

# Load the Gemini model
model = GenerativeModel("gemini-2.5-flash")
chat = model.start_chat()

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/chat', methods=['POST'])
def chat_handler():
    user_message = request.json.get('message')
    if not user_message:
        return jsonify({'error': 'Message is required'}), 400

    try:
        responses = chat.send_message(
            user_message,
            generation_config={
                "max_output_tokens": 8192,
                "temperature": 0.9,
                "top_p": 1.0,
                "top_k": 32
            },
            stream=True
        )
        
        def generate():
            for response in responses:
                yield response.text

        return ''.join(list(generate()))

    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8080)
