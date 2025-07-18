# myVertexGemini - Gemini 2.5 Flash 채팅 애플리케이션

Google Vertex AI의 Gemini 2.5 Flash 모델을 사용한 Flask 기반 웹 채팅 애플리케이션입니다.

## 📁 프로젝트 구조

```
myVertexGemini/
├── app.py                # Flask 웹 애플리케이션 메인 파일
├── gemini-example.py     # 콘솔 기반 채팅 예제
├── requirements.txt      # Python 의존성 패키지
├── Dockerfile           # Docker 컨테이너 설정
├── templates/
│   └── index.html       # 웹 채팅 인터페이스
├── DEVELOPER_DOCS.md    # 개발자 문서
└── README.md           # 이 파일
```

## 🔧 사전 준비사항

### 1. Google Cloud 프로젝트 설정
1. [Google Cloud Console](https://console.cloud.google.com/)에서 프로젝트 생성
2. 결제 계정 연결
3. 필요한 API 활성화:
   ```bash
   gcloud services enable aiplatform.googleapis.com
   gcloud services enable run.googleapis.com
   gcloud services enable cloudbuild.googleapis.com
   ```

### 2. Vertex AI 권한 설정

#### 서비스 계정 생성 및 권한 부여
```bash
# 서비스 계정 생성
gcloud iam service-accounts create vertex-ai-service-account \
    --display-name="Vertex AI Service Account"

# Vertex AI User 권한 부여
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:vertex-ai-service-account@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/aiplatform.user"

# 키 파일 생성 (로컬 개발용)
gcloud iam service-accounts keys create vertex-ai-key.json \
    --iam-account=vertex-ai-service-account@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

#### 환경 변수 설정 (로컬 개발용)
```bash
export GOOGLE_APPLICATION_CREDENTIALS="./vertex-ai-key.json"
export GOOGLE_CLOUD_PROJECT="YOUR_PROJECT_ID"
```

#### Cloud Run 배포용 권한 설정
```bash
# Cloud Run에서 Vertex AI 사용을 위한 권한
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:YOUR_PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
    --role="roles/aiplatform.user"
```

## 🐍 Anaconda 가상환경 설정

### 1. Anaconda 설치
- [Anaconda 공식 웹사이트](https://www.anaconda.com/products/distribution)에서 다운로드 및 설치

### 2. 가상환경 생성 및 활성화
```bash
# 가상환경 생성 (Python 3.9)
conda create -n myvertexgemini python=3.9

# 가상환경 활성화
conda activate myvertexgemini

# 의존성 설치
pip install -r requirements.txt
```

### 3. 환경 변수 설정
```bash
# Windows
set GOOGLE_APPLICATION_CREDENTIALS=vertex-ai-key.json
set GOOGLE_CLOUD_PROJECT=YOUR_PROJECT_ID

# macOS/Linux
export GOOGLE_APPLICATION_CREDENTIALS="./vertex-ai-key.json"
export GOOGLE_CLOUD_PROJECT="YOUR_PROJECT_ID"
```

## 🧪 로컬 테스트

### 1. Flask 웹 애플리케이션 실행
```bash
# 가상환경 활성화
conda activate myvertexgemini

# 애플리케이션 실행
python app.py
```

브라우저에서 `http://localhost:8080` 접속하여 채팅 인터페이스 테스트

### 2. 콘솔 기반 채팅 테스트
```bash
# 콘솔 채팅 예제 실행
python gemini-example.py
```

### 3. Docker 로컬 테스트
```bash
# Docker 이미지 빌드
docker build -t myvertexgemini .

# 컨테이너 실행 (환경 변수 전달)
docker run -p 8080:8080 \
  -e GOOGLE_APPLICATION_CREDENTIALS=/app/vertex-ai-key.json \
  -e GOOGLE_CLOUD_PROJECT=YOUR_PROJECT_ID \
  -v $(pwd)/vertex-ai-key.json:/app/vertex-ai-key.json \
  myvertexgemini
```

## ☁️ Cloud Run 배포

### 방법 1: 소스코드 직접 배포

#### 1. gcloud CLI 설정
```bash
# Google Cloud CLI 설치 및 인증
gcloud auth login

# 프로젝트 설정
gcloud config set project YOUR_PROJECT_ID

# 기본 리전 설정
gcloud config set run/region us-central1
```

#### 2. 소스코드 배포
```bash
# Cloud Run에 직접 배포
gcloud run deploy myvertexgemini \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars GOOGLE_CLOUD_PROJECT=YOUR_PROJECT_ID \
  --memory 1Gi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 10
```

### 방법 2: 컨테이너 이미지 배포

#### 1. Container Registry에 이미지 푸시
```bash
# 프로젝트 ID 설정
export PROJECT_ID=YOUR_PROJECT_ID

# Docker 이미지 빌드 및 태그
docker build -t gcr.io/$PROJECT_ID/myvertexgemini .

# Container Registry에 푸시
docker push gcr.io/$PROJECT_ID/myvertexgemini
```

#### 2. Cloud Run에 컨테이너 배포
```bash
# 컨테이너 이미지로 배포
gcloud run deploy myvertexgemini \
  --image gcr.io/$PROJECT_ID/myvertexgemini \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars GOOGLE_CLOUD_PROJECT=$PROJECT_ID \
  --memory 1Gi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 10
```

#### 3. Artifact Registry 사용 (권장)
```bash
# Artifact Registry 저장소 생성
gcloud artifacts repositories create myvertexgemini \
  --repository-format=docker \
  --location=us-central1

# Docker 인증 설정
gcloud auth configure-docker us-central1-docker.pkg.dev

# 이미지 빌드 및 태그
docker build -t us-central1-docker.pkg.dev/$PROJECT_ID/myvertexgemini/app .

# Artifact Registry에 푸시
docker push us-central1-docker.pkg.dev/$PROJECT_ID/myvertexgemini/app

# Cloud Run에 배포
gcloud run deploy myvertexgemini \
  --image us-central1-docker.pkg.dev/$PROJECT_ID/myvertexgemini/app \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars GOOGLE_CLOUD_PROJECT=$PROJECT_ID
```

## 🔒 보안 설정

### 1. IAM 권한 최소화
```bash
# 최소 권한 사용자 정의 역할 생성
gcloud iam roles create vertexai_minimal_access \
  --project=$PROJECT_ID \
  --title="Vertex AI Minimal Access" \
  --description="Minimal permissions for Vertex AI" \
  --permissions="aiplatform.endpoints.predict,aiplatform.models.predict"
```

### 2. VPC 연결 (선택사항)
```bash
# VPC 커넥터 생성
gcloud compute networks vpc-access connectors create myvertexgemini-connector \
  --region=us-central1 \
  --subnet=default \
  --subnet-project=$PROJECT_ID

# Cloud Run 서비스에 VPC 연결
gcloud run services update myvertexgemini \
  --vpc-connector=myvertexgemini-connector \
  --region=us-central1
```

## 📊 모니터링 및 로깅

### 1. Cloud Monitoring 설정
```bash
# 알림 정책 생성 (CPU 사용률)
gcloud alpha monitoring policies create \
  --policy-from-file=monitoring-policy.yaml
```

### 2. 로그 확인
```bash
# Cloud Run 로그 확인
gcloud logs read "resource.type=cloud_run_revision" --limit=50

# 실시간 로그 스트리밍
gcloud logs tail "resource.type=cloud_run_revision"
```

## 🚀 성능 최적화

### 1. Cold Start 최소화
- 최소 인스턴스 수 설정: `--min-instances 1`
- 메모리 할당 최적화: `--memory 512Mi`

### 2. 자동 스케일링 설정
```bash
# 동시성 및 최대 인스턴스 설정
gcloud run services update myvertexgemini \
  --concurrency=80 \
  --max-instances=10 \
  --region=us-central1
```

## 🔧 환경별 설정

### 개발 환경
```bash
# 디버그 모드 활성화
gcloud run services update myvertexgemini \
  --set-env-vars DEBUG=True \
  --region=us-central1
```

### 프로덕션 환경
```bash
# 디버그 모드 비활성화 및 최적화
gcloud run services update myvertexgemini \
  --set-env-vars DEBUG=False \
  --memory 1Gi \
  --cpu 2 \
  --min-instances 1 \
  --max-instances 20 \
  --region=us-central1
```

## 📝 주요 설정 파일

### app.py 프로젝트 ID 수정
```python
# app.py 8-9번째 줄 수정
PROJECT_ID = "YOUR_PROJECT_ID"  # 실제 프로젝트 ID로 변경
LOCATION = "us-central1"        # 원하는 리전으로 변경
```

### requirements.txt
```
flask
google-cloud-aiplatform
```

## 🐛 문제 해결

### 1. 권한 오류
```bash
# 서비스 계정 권한 확인
gcloud projects get-iam-policy YOUR_PROJECT_ID

# Vertex AI API 활성화 확인
gcloud services list --enabled --filter="name:aiplatform.googleapis.com"
```

### 2. 배포 오류
```bash
# Cloud Run 서비스 상태 확인
gcloud run services describe myvertexgemini --region=us-central1

# 로그 확인
gcloud logs read "resource.type=cloud_run_revision" --limit=10
```

### 3. 네트워크 오류
- 방화벽 규칙 확인
- VPC 설정 확인
- Cloud NAT 설정 (필요시)

## 📚 참고 자료

- [Vertex AI 문서](https://cloud.google.com/vertex-ai/docs)
- [Cloud Run 문서](https://cloud.google.com/run/docs)
- [Gemini API 문서](https://cloud.google.com/vertex-ai/docs/generative-ai/model-reference/gemini)
- [Flask 문서](https://flask.palletsprojects.com/)

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.