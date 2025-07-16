#!/bin/bash

echo "Gemini 챗봇 로컬 테스트 스크립트"
echo "================================"

# API 키 확인
if [ -z "$GOOGLE_API_KEY" ]; then
    echo "❌ GOOGLE_API_KEY 환경 변수가 설정되지 않았습니다."
    echo "다음 명령어로 설정해주세요:"
    echo "export GOOGLE_API_KEY='your-api-key'"
    exit 1
fi

echo "✅ API 키가 설정되었습니다."

# 가상환경 확인 및 생성
if [ ! -d "venv" ]; then
    echo "📦 가상환경을 생성합니다..."
    python3 -m venv venv
fi

# 가상환경 활성화
echo "🔧 가상환경을 활성화합니다..."
source venv/bin/activate

# 의존성 설치
echo "📚 의존성을 설치합니다..."
pip install -r requirements.txt

# Flask 앱 실행
echo "🚀 Flask 애플리케이션을 시작합니다..."
echo "브라우저에서 http://localhost:8080 으로 접속하세요."
echo "종료하려면 Ctrl+C를 누르세요."

python app.py