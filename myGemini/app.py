import os
from flask import Flask, render_template, request, jsonify
import google.generativeai as genai
from flask_cors import CORS
from dotenv import load_dotenv

# .env 파일 로드
load_dotenv()

app = Flask(__name__)
CORS(app)

# Gemini API 키 설정
GOOGLE_API_KEY = os.environ.get('GOOGLE_API_KEY')
if not GOOGLE_API_KEY:
    raise ValueError("GOOGLE_API_KEY 환경 변수가 설정되지 않았습니다.")

genai.configure(api_key=GOOGLE_API_KEY)

# Gemini 2.5 Flash 모델 초기화
#model = genai.GenerativeModel('gemini-2.0-flash-exp')
model = genai.GenerativeModel('gemini-2.5-flash')

# 대화 기록을 저장할 변수
conversation_history = []

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/chat', methods=['POST'])
def chat():
    try:
        user_message = request.json.get('message', '')
        
        if not user_message:
            return jsonify({'error': '메시지가 비어있습니다.'}), 400
        
        # 대화 기록에 사용자 메시지 추가
        conversation_history.append(f"사용자: {user_message}")
        
        # 전체 대화 컨텍스트 생성
        context = "\n".join(conversation_history[-10:])  # 최근 10개 메시지만 유지
        
        # Gemini 모델에 요청
        response = model.generate_content(context)
        ai_response = response.text
        
        # 대화 기록에 AI 응답 추가
        conversation_history.append(f"AI: {ai_response}")
        
        return jsonify({
            'response': ai_response,
            'status': 'success'
        })
        
    except Exception as e:
        return jsonify({
            'error': f'오류가 발생했습니다: {str(e)}',
            'status': 'error'
        }), 500

@app.route('/clear', methods=['POST'])
def clear_conversation():
    global conversation_history
    conversation_history = []
    return jsonify({'status': 'success', 'message': '대화 기록이 초기화되었습니다.'})

if __name__ == '__main__':
    # Cloud Run에서는 PORT 환경 변수를 사용
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port, debug=False)
