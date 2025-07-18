# myChatApp - Flask 채팅 애플리케이션

간단한 Flask 기반 실시간 채팅 애플리케이션입니다. 로컬 환경에서 테스트 후 Google Cloud Run으로 배포할 수 있습니다.

## 프로젝트 구조
```
myChatApp/
├── main.py              # Flask 애플리케이션 메인 파일
├── requirements.txt     # Python 의존성 패키지 목록
├── Dockerfile          # Docker 컨테이너 빌드 설정
├── cloudbuild.yaml     # Cloud Build 구성 파일
├── static/
│   └── style.css       # CSS 스타일 파일
└── templates/
    └── index.html      # HTML 템플릿
```

## 1. 아나콘다 가상환경 설정

### 1.1 아나콘다 설치
- [Anaconda 공식 웹사이트](https://www.anaconda.com/products/distribution)에서 운영체제에 맞는 버전을 다운로드하여 설치합니다.

### 1.2 가상환경 생성
```bash
# 가상환경 생성 (Python 3.11 사용)
conda create -n mychatapp python=3.11

# 가상환경 활성화
conda activate mychatapp
```

### 1.3 의존성 패키지 설치
```bash
# requirements.txt에 명시된 패키지 설치
pip install -r requirements.txt
```

## 2. 로컬 환경에서 테스트

### 2.1 애플리케이션 실행
```bash
# 가상환경이 활성화된 상태에서 실행
python main.py
```

### 2.2 애플리케이션 접속
- 웹 브라우저에서 `http://localhost:8080` 접속
- 채팅 메시지를 입력하고 전송 버튼을 클릭하여 테스트

### 2.3 로컬 테스트 확인사항
- 메시지 전송이 정상적으로 작동하는지 확인
- 전송된 메시지가 화면에 표시되는지 확인
- 브라우저 개발자 도구(F12)에서 네트워크 탭을 확인하여 API 호출이 정상적으로 이루어지는지 확인

## 3. Google Cloud Run 배포

Cloud Run으로 배포하는 방법은 두 가지가 있습니다: Docker 이미지를 사용하는 방법과 소스코드를 직접 배포하는 방법입니다.

### 3.1 사전 준비사항
1. Google Cloud 계정 생성 및 프로젝트 설정
2. Google Cloud SDK 설치 ([설치 가이드](https://cloud.google.com/sdk/docs/install))
3. Google Cloud 인증 및 프로젝트 설정:
```bash
# Google Cloud 로그인
gcloud auth login

# 프로젝트 ID 설정 (your-project-id를 실제 프로젝트 ID로 변경)
gcloud config set project your-project-id

# Cloud Run API 활성화
gcloud services enable run.googleapis.com
```

### 3.2 방법 1: Docker 이미지를 사용한 배포

#### 3.2.1 Docker 설치
- [Docker 공식 웹사이트](https://www.docker.com/get-started)에서 Docker Desktop 설치

#### 3.2.2 Docker 이미지 빌드 및 푸시
```bash
# Docker 이미지 빌드 (프로젝트 ID와 이미지 이름 설정)
docker build -t gcr.io/your-project-id/mychatapp:latest .

# Google Container Registry에 이미지 푸시를 위한 인증
gcloud auth configure-docker

# 이미지 푸시
docker push gcr.io/your-project-id/mychatapp:latest
```

#### 3.2.3 Cloud Run으로 배포
```bash
# Cloud Run 서비스 배포
gcloud run deploy mychatapp \
  --image gcr.io/your-project-id/mychatapp:latest \
  --platform managed \
  --region asia-northeast3 \
  --allow-unauthenticated \
  --port 8080
```

### 3.3 방법 2: 소스코드 직접 배포 (Source Deploy)

Cloud Run은 소스코드를 직접 배포할 수 있는 기능을 제공합니다. 이 방법은 Docker 이미지를 직접 빌드할 필요가 없습니다.

#### 3.3.1 소스코드 직접 배포
```bash
# 현재 디렉토리의 소스코드를 Cloud Run으로 직접 배포
gcloud run deploy mychatapp \
  --source . \
  --platform managed \
  --region asia-northeast3 \
  --allow-unauthenticated
```

#### 3.3.2 배포 옵션 설명
- `--source .`: 현재 디렉토리의 소스코드를 사용
- Cloud Run이 자동으로 Dockerfile을 감지하여 이미지를 빌드
- Dockerfile이 없는 경우, Google Cloud Buildpacks를 사용하여 자동으로 컨테이너 이미지 생성

### 3.4 자동 배포 설정 (선택사항)
Cloud Build를 사용하여 자동 배포를 설정할 수 있습니다:

```bash
# Cloud Build API 활성화
gcloud services enable cloudbuild.googleapis.com

# Cloud Build 트리거 생성 (GitHub 저장소와 연결 필요)
gcloud builds submit --config cloudbuild.yaml
```

## 4. 배포 확인
1. Cloud Run 배포 완료 후 제공되는 URL로 접속
2. 로컬 환경과 동일하게 채팅 기능 테스트
3. Cloud Console에서 로그 및 메트릭 확인

## 5. 문제 해결
- **포트 관련 오류**: Cloud Run은 `PORT` 환경변수를 사용합니다. main.py에서 포트를 8080으로 고정했는지 확인
- **이미지 푸시 실패**: `gcloud auth configure-docker` 명령을 실행했는지 확인
- **배포 실패**: Cloud Run 서비스 로그를 확인하여 오류 메시지 파악

## 6. 정리
### 로컬 환경 정리
```bash
# 가상환경 비활성화
conda deactivate

# 가상환경 삭제 (필요시)
conda env remove -n mychatapp
```

### Cloud Run 서비스 삭제
```bash
# Cloud Run 서비스 삭제
gcloud run services delete mychatapp --region asia-northeast3
```

## 추가 리소스
- [Flask 공식 문서](https://flask.palletsprojects.com/)
- [Google Cloud Run 문서](https://cloud.google.com/run/docs)
- [Docker 문서](https://docs.docker.com/)