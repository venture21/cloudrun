# Vertex AI Gemini Chat App

Flask 기반의 Vertex AI Gemini 챗봇 애플리케이션입니다. 다양한 플랫폼(Android, iOS)에서 사용할 수 있는 백엔드 API를 제공합니다.

## 프로젝트 구조

```
VertexGeminiApp/
├── app.py              # Flask 메인 애플리케이션
├── requirements.txt    # Python 의존성
├── Dockerfile         # 컨테이너 빌드 파일
├── deploy.sh          # 배포 스크립트
├── test_server.py     # 서버 테스트 파일
├── android/           # Android 앱
├── ios/              # iOS 앱
└── README.md         # 프로젝트 문서
```

## 로컬 개발 환경 설정

### 1. Anaconda 가상환경 설정

```bash
# 1. Anaconda 설치 (이미 설치된 경우 건너뛰기)
# Windows/macOS/Linux에서 Anaconda 다운로드: https://www.anaconda.com/products/distribution

# 2. 가상환경 생성
conda create -n vertex-gemini python=3.11 -y

# 3. 가상환경 활성화
conda activate vertex-gemini

# 4. 필요한 패키지 설치
pip install -r requirements.txt
```

### 2. Google Cloud 인증 설정

```bash
# Google Cloud SDK 설치 후
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

### 3. 환경변수 설정

```bash
# Linux/macOS
export PROJECT_ID="your-project-id"
export LOCATION="us-central1"
export FLASK_ENV="development"

# Windows (PowerShell)
$env:PROJECT_ID="your-project-id"
$env:LOCATION="us-central1"
$env:FLASK_ENV="development"
```

### 4. 로컬 서버 실행

```bash
# 개발 모드로 실행
python app.py

# 또는 스크립트 사용
./start_local_server.sh
```

서버가 `http://localhost:8080`에서 실행됩니다.

### 5. 로컬 테스트

```bash
# 헬스 체크 테스트
curl http://localhost:8080/health

# 채팅 API 테스트
curl -X POST http://localhost:8080/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "안녕하세요", "session_id": "test"}'

# 또는 테스트 스크립트 실행
python test_server.py
```

## Google Cloud Run 배포

### 방법 1: 소스코드 직접 배포

```bash
# 1. Google Cloud CLI 설치 및 인증
gcloud auth login
gcloud config set project YOUR_PROJECT_ID

# 2. Cloud Run 서비스 배포
gcloud run deploy vertex-gemini-app \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars PROJECT_ID=YOUR_PROJECT_ID,LOCATION=us-central1

# 3. 배포 완료 후 URL 확인
gcloud run services describe vertex-gemini-app --region us-central1 --format 'value(status.url)'
```

### 방법 2: Docker 컨테이너 배포

```bash
# 1. Docker 이미지 빌드
docker build -t gcr.io/YOUR_PROJECT_ID/vertex-gemini-app .

# 2. Google Container Registry에 푸시
docker push gcr.io/YOUR_PROJECT_ID/vertex-gemini-app

# 3. Cloud Run에 배포
gcloud run deploy vertex-gemini-app \
  --image gcr.io/YOUR_PROJECT_ID/vertex-gemini-app \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars PROJECT_ID=YOUR_PROJECT_ID,LOCATION=us-central1

# 또는 Artifact Registry 사용 (권장)
# 1. Artifact Registry 저장소 생성
gcloud artifacts repositories create vertex-gemini-repo \
  --repository-format=docker \
  --location=us-central1

# 2. Docker 이미지 태그 및 푸시
docker tag vertex-gemini-app us-central1-docker.pkg.dev/YOUR_PROJECT_ID/vertex-gemini-repo/vertex-gemini-app
docker push us-central1-docker.pkg.dev/YOUR_PROJECT_ID/vertex-gemini-repo/vertex-gemini-app

# 3. Cloud Run에 배포
gcloud run deploy vertex-gemini-app \
  --image us-central1-docker.pkg.dev/YOUR_PROJECT_ID/vertex-gemini-repo/vertex-gemini-app \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars PROJECT_ID=YOUR_PROJECT_ID,LOCATION=us-central1
```

### 자동 배포 스크립트 사용

```bash
# deploy.sh 스크립트에 실행 권한 부여
chmod +x deploy.sh

# 스크립트 실행
./deploy.sh
```

## Vertex AI Studio 권한 설정

### 1. Google Cloud Console에서 권한 설정

1. **Google Cloud Console** (https://console.cloud.google.com)에 로그인
2. 프로젝트 선택
3. **IAM 및 관리자 > IAM** 메뉴로 이동
4. 서비스 계정 또는 사용자에게 다음 역할 부여:
   - `Vertex AI User` 또는 `Vertex AI Administrator`
   - `AI Platform Developer`

### 2. 필요한 API 활성화

```bash
# Vertex AI API 활성화
gcloud services enable aiplatform.googleapis.com

# Compute Engine API 활성화 (필요한 경우)
gcloud services enable compute.googleapis.com
```

### 3. 서비스 계정 생성 및 키 다운로드 (선택사항)

```bash
# 1. 서비스 계정 생성
gcloud iam service-accounts create vertex-ai-service \
  --display-name="Vertex AI Service Account"

# 2. 권한 부여
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:vertex-ai-service@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/aiplatform.user"

# 3. 키 파일 다운로드
gcloud iam service-accounts keys create vertex-ai-key.json \
  --iam-account=vertex-ai-service@YOUR_PROJECT_ID.iam.gserviceaccount.com

# 4. 환경변수 설정
export GOOGLE_APPLICATION_CREDENTIALS="path/to/vertex-ai-key.json"
```

### 4. Cloud Run에서 서비스 계정 사용

```bash
# Cloud Run 배포 시 서비스 계정 지정
gcloud run deploy vertex-gemini-app \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --service-account=vertex-ai-service@YOUR_PROJECT_ID.iam.gserviceaccount.com \
  --set-env-vars PROJECT_ID=YOUR_PROJECT_ID,LOCATION=us-central1
```

## API 엔드포인트

### Health Check
```
GET /health
```

### 채팅
```
POST /chat
Content-Type: application/json

{
  "message": "사용자 메시지",
  "session_id": "선택적 세션 ID"
}
```

### 채팅 세션 리셋
```
POST /chat/reset
Content-Type: application/json

{
  "session_id": "리셋할 세션 ID"
}
```

## 환경변수

- `PROJECT_ID`: Google Cloud 프로젝트 ID (기본값: sesac-dev-400904)
- `LOCATION`: Vertex AI 지역 (기본값: us-central1)
- `PORT`: 서버 포트 (기본값: 8080)
- `FLASK_ENV`: Flask 환경 (development/production)

## 모바일 앱 연동

### Android 앱

1. `android/` 폴더를 Android Studio에서 열기
2. `ChatRepository.kt`에서 base URL 업데이트:
   - 에뮬레이터용: `http://10.0.2.2:8080/`
   - 실제 기기용: 컴퓨터의 IP 주소 사용
   - Cloud Run 배포 후: Cloud Run URL 사용
3. 에뮬레이터 또는 실제 기기에서 실행

### iOS 앱

1. `ios/GeminiChat/`를 Xcode에서 열기
2. `ChatService.swift`에서 base URL 업데이트:
   - 시뮬레이터용: `http://localhost:8080`
   - 실제 기기용: 컴퓨터의 IP 주소 사용
   - Cloud Run 배포 후: Cloud Run URL 사용
3. 시뮬레이터 또는 실제 기기에서 실행

## 주요 기능

- Vertex AI Gemini와의 실시간 채팅
- KST(한국 표준시) 기준 메시지 타임스탬프
- 세션 관리 및 채팅 히스토리
- 오류 처리 및 연결 상태 관리
- Android/iOS 양쪽 플랫폼 지원

## 문제 해결

### 1. 인증 오류
```bash
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

### 2. Vertex AI API 오류
- API가 활성화되어 있는지 확인
- 프로젝트에 Vertex AI 권한이 있는지 확인
- 지역 설정이 올바른지 확인

### 3. Docker 빌드 오류
```bash
# Docker 이미지 다시 빌드
docker build --no-cache -t vertex-gemini-app .
```

### 4. 네트워크 연결 오류
- 방화벽 설정 확인
- 포트 8080이 열려 있는지 확인
- 모바일 앱에서 올바른 URL 사용 확인

## 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다.