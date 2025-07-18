# myGemini - Gemini Chat Application

Flask 기반의 Google Gemini AI 챗봇 애플리케이션입니다.

## 목차
- [로컬 환경 설정](#로컬-환경-설정)
- [로컬 테스트](#로컬-테스트)
- [Cloud Run 배포](#cloud-run-배포)
  - [소스 코드 직접 배포](#1-소스-코드-직접-배포)
  - [컨테이너 이미지로 배포](#2-컨테이너-이미지로-배포)
- [API 키 설정 방법](#api-키-설정-방법)

## 로컬 환경 설정

### 1. Anaconda 가상환경 생성 및 활성화

```bash
# 가상환경 생성 (Python 3.11 권장)
conda create -n mygemini python=3.11

# 가상환경 활성화
conda activate mygemini

# 가상환경 비활성화 (필요시)
conda deactivate
```

### 2. 의존성 패키지 설치

```bash
# 가상환경이 활성화된 상태에서
pip install -r requirements.txt
```

### 3. 환경 변수 설정

`.env` 파일을 생성하고 Google AI Studio API 키를 추가:

```bash
# .env 파일 생성
echo "GOOGLE_API_KEY=your-api-key-here" > .env
```

## 로컬 테스트

```bash
# Flask 앱 실행
python app.py

# 또는 스크립트 실행
chmod +x test_local.sh
./test_local.sh
```

브라우저에서 `http://localhost:8080` 접속하여 테스트

## Cloud Run 배포

### 사전 준비
```bash
# GCP 프로젝트 설정
gcloud config set project YOUR-PROJECT-ID

# Cloud Run API 활성화
gcloud services enable run.googleapis.com

# Artifact Registry API 활성화 (컨테이너 배포시 필요)
gcloud services enable artifactregistry.googleapis.com
```

### 1. 소스 코드 직접 배포

#### 방법 1-1: 환경 변수로 API 키 설정

```bash
# 소스에서 직접 배포 (API 키를 환경 변수로 전달)
gcloud run deploy mygemini \
  --source . \
  --region asia-northeast3 \
  --platform managed \
  --allow-unauthenticated \
  --set-env-vars GOOGLE_API_KEY="your-api-key-here"
```

#### 방법 1-2: Secret Manager 사용

```bash
# 1. Secret Manager API 활성화
gcloud services enable secretmanager.googleapis.com

# 2. Secret 생성
echo -n "your-api-key-here" | gcloud secrets create google-api-key \
  --data-file=-

# 3. Cloud Run 서비스 계정에 권한 부여
PROJECT_NUMBER=$(gcloud projects describe $(gcloud config get-value project) --format="value(projectNumber)")
gcloud secrets add-iam-policy-binding google-api-key \
  --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"

# 4. Secret을 사용하여 배포
gcloud run deploy mygemini \
  --source . \
  --region asia-northeast3 \
  --platform managed \
  --allow-unauthenticated \
  --set-secrets="GOOGLE_API_KEY=google-api-key:latest"
```

### 2. 컨테이너 이미지로 배포

#### 방법 2-1: 환경 변수로 API 키 설정

```bash
# 1. Artifact Registry 저장소 생성 (최초 1회)
gcloud artifacts repositories create myapp-repo \
  --repository-format=docker \
  --location=asia-northeast3

# 2. Docker 인증 설정
gcloud auth configure-docker asia-northeast3-docker.pkg.dev

# 3. 컨테이너 이미지 빌드 및 푸시
PROJECT_ID=$(gcloud config get-value project)
docker build -t asia-northeast3-docker.pkg.dev/${PROJECT_ID}/myapp-repo/mygemini:latest .
docker push asia-northeast3-docker.pkg.dev/${PROJECT_ID}/myapp-repo/mygemini:latest

# 4. Cloud Run에 배포 (환경 변수로 API 키 전달)
gcloud run deploy mygemini \
  --image asia-northeast3-docker.pkg.dev/${PROJECT_ID}/myapp-repo/mygemini:latest \
  --region asia-northeast3 \
  --platform managed \
  --allow-unauthenticated \
  --set-env-vars GOOGLE_API_KEY="your-api-key-here"
```

#### 방법 2-2: Secret Manager 사용

```bash
# 1-3번 단계는 위의 컨테이너 빌드 과정과 동일

# 4. Secret Manager를 사용하여 배포
gcloud run deploy mygemini \
  --image asia-northeast3-docker.pkg.dev/${PROJECT_ID}/myapp-repo/mygemini:latest \
  --region asia-northeast3 \
  --platform managed \
  --allow-unauthenticated \
  --set-secrets="GOOGLE_API_KEY=google-api-key:latest"
```

## API 키 설정 방법

### 1. Google AI Studio에서 API 키 발급
1. [Google AI Studio](https://aistudio.google.com/apikey) 접속
2. "Create API Key" 클릭
3. 생성된 API 키 복사

### 2. Secret Manager 추가 설정

#### Secret 업데이트
```bash
# 새로운 버전으로 Secret 업데이트
echo -n "new-api-key-here" | gcloud secrets versions add google-api-key \
  --data-file=-
```

#### Secret 버전 관리
```bash
# Secret 버전 목록 확인
gcloud secrets versions list google-api-key

# 특정 버전 사용
gcloud run services update mygemini \
  --region asia-northeast3 \
  --update-secrets="GOOGLE_API_KEY=google-api-key:2"  # 버전 2 사용
```

## 배포 확인

```bash
# 서비스 URL 확인
gcloud run services describe mygemini --region asia-northeast3 --format="value(status.url)"

# 로그 확인
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=mygemini" --limit 50
```

## 추가 명령어

### 서비스 삭제
```bash
# Cloud Run 서비스 삭제
gcloud run services delete mygemini --region asia-northeast3

# Secret 삭제
gcloud secrets delete google-api-key

# Artifact Registry 이미지 삭제
gcloud artifacts docker images delete \
  asia-northeast3-docker.pkg.dev/${PROJECT_ID}/myapp-repo/mygemini
```

### 서비스 업데이트
```bash
# 메모리 제한 변경
gcloud run services update mygemini \
  --region asia-northeast3 \
  --memory 512Mi

# 동시 요청 수 제한
gcloud run services update mygemini \
  --region asia-northeast3 \
  --concurrency 80
```

## 주의사항

1. **API 키 보안**: API 키를 코드에 하드코딩하지 마세요. 항상 환경 변수나 Secret Manager를 사용하세요.
2. **비용 관리**: Cloud Run은 사용한 만큼만 비용이 발생하지만, 트래픽이 많을 경우 비용이 증가할 수 있습니다.
3. **리전 선택**: 지연 시간을 최소화하기 위해 사용자와 가까운 리전을 선택하세요.
4. **Secret Manager 권한**: Cloud Run 서비스 계정에 Secret Accessor 권한이 있는지 확인하세요.

## 문제 해결

### 배포 실패 시
```bash
# 상세 로그 확인
gcloud logging read "resource.type=build" --limit 10

# Cloud Run 서비스 상태 확인
gcloud run services describe mygemini --region asia-northeast3
```

### API 키 관련 오류
- 환경 변수가 제대로 설정되었는지 확인
- Secret Manager 권한이 올바르게 설정되었는지 확인
- API 키가 유효한지 Google AI Studio에서 확인