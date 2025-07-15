# Flask 채팅 앱 - Cloud Run 예제

Flask와 Socket.IO를 사용한 실시간 채팅 애플리케이션입니다.

## 기능
- 실시간 메시지 전송
- 사용자 이름 설정
- 타이핑 표시 기능
- 이전 메시지 히스토리 표시 (최대 100개)

## 로컬 테스트

### 1. 가상환경 설정 및 패키지 설치
```bash
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 2. 애플리케이션 실행
```bash
python app.py
```

브라우저에서 http://localhost:8080 접속

## Google Cloud Run 배포

### 1. Google Cloud CLI 설치 및 인증
```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

### 2. Artifact Registry 설정 (처음 한 번만)
```bash
gcloud artifacts repositories create cloud-run-source-deploy \
    --repository-format=docker \
    --location=asia-northeast3
```

### 3. Cloud Run 배포
```bash
gcloud run deploy flask-chat-app \
    --source . \
    --region=asia-northeast3 \
    --allow-unauthenticated \
    --port=8080 \
    --min-instances=0 \
    --max-instances=100
```

### 4. 환경 변수 설정 (선택사항)
```bash
gcloud run services update flask-chat-app \
    --update-env-vars SECRET_KEY=your-secure-secret-key \
    --region=asia-northeast3
```

## 주의사항
- Cloud Run은 WebSocket을 완전히 지원하지 않으므로, Socket.IO는 HTTP long-polling으로 폴백됩니다
- 실제 프로덕션 환경에서는 Redis나 Cloud Memorystore를 사용하여 인스턴스 간 메시지를 동기화해야 합니다
- SECRET_KEY는 안전한 값으로 변경해야 합니다

## 파일 구조
```
.
├── app.py              # Flask 애플리케이션
├── requirements.txt    # Python 패키지
├── Dockerfile         # Docker 설정
├── .dockerignore      # Docker 제외 파일
├── templates/
│   └── index.html     # 채팅 UI
└── static/
    ├── css/
    │   └── style.css  # 스타일시트
    └── js/
        └── chat.js    # 클라이언트 JavaScript
```