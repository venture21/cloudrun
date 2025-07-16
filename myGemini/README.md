# Gemini 2.5 Flash 챗봇

Google Gemini 2.5 Flash 모델을 사용한 웹 기반 챗봇 애플리케이션입니다.

## 로컬 테스트

1. **Google API 키 설정**
   ```bash
   export GOOGLE_API_KEY="your-gemini-api-key"
   ```

2. **가상환경 생성 및 활성화**
   ```bash
   python -m venv venv
   source venv/bin/activate  # Linux/Mac
   # 또는
   venv\Scripts\activate  # Windows
   ```

3. **의존성 설치**
   ```bash
   pip install -r requirements.txt
   ```

4. **애플리케이션 실행**
   ```bash
   python app.py
   ```

5. **브라우저에서 접속**
   - http://localhost:8080

## Cloud Run 배포

1. **Google Cloud CLI 설치 및 인증**
   ```bash
   gcloud auth login
   gcloud config set project YOUR-PROJECT-ID
   ```

2. **Docker 이미지 빌드 및 푸시**
   ```bash
   gcloud builds submit --tag gcr.io/YOUR-PROJECT-ID/gemini-chatbot
   ```

3. **Cloud Run에 배포**
   ```bash
   gcloud run deploy gemini-chatbot \
     --image gcr.io/YOUR-PROJECT-ID/gemini-chatbot \
     --platform managed \
     --region asia-northeast3 \
     --allow-unauthenticated \
     --set-env-vars GOOGLE_API_KEY=your-gemini-api-key
   ```

## 환경 변수

- `GOOGLE_API_KEY`: Gemini API 키 (필수)
- `PORT`: 서버 포트 (기본값: 8080)

## 주요 기능

- Gemini 2.5 Flash 모델을 사용한 대화형 챗봇
- 실시간 채팅 인터페이스
- 대화 기록 관리
- 대화 초기화 기능
- 반응형 웹 디자인