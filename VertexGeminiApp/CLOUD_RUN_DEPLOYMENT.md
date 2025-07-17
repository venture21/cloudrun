# Cloud Run 배포 가이드

## 1. Cloud Run 배포하기

```bash
# 배포 스크립트 실행
./deploy.sh
```

배포 완료 후 Cloud Run URL을 확인하세요 (예: `https://gemini-chat-app-xyz-uc.a.run.app`)

## 2. Android 앱 업데이트

배포 완료 후 받은 Cloud Run URL로 Android 앱을 업데이트:

```bash
# Cloud Run URL로 Android 앱 업데이트
./update_android_url.sh https://your-actual-cloud-run-url.run.app
```

## 3. 빌드 구성

### Debug 빌드 (개발용)
- 로컬 서버 사용: `http://10.0.2.2:8080/`
- 에뮬레이터에서 로컬 Flask 서버에 연결

### Release 빌드 (배포용)
- Cloud Run URL 사용: `https://your-cloud-run-url.run.app/`
- 실제 프로덕션 환경에서 사용

## 4. 테스트하기

### 1. Cloud Run 서비스 테스트
```bash
curl https://your-cloud-run-url.run.app/health
```

### 2. Android 앱 테스트
1. Android Studio에서 **Release** 빌드로 변경
2. 앱을 빌드하고 실행
3. 채팅 기능이 정상 작동하는지 확인

## 5. 환경 설정

### 필요한 환경 변수
- `PROJECT_ID`: GCP 프로젝트 ID (기본값: sesac-dev-400904)
- `LOCATION`: Vertex AI 위치 (기본값: us-central1)

### 필요한 API 활성화
- Cloud Build API
- Cloud Run API  
- Vertex AI API

## 6. 배포 후 확인사항

✅ Cloud Run 서비스가 정상 실행 중  
✅ /health 엔드포인트 응답 확인  
✅ Android 앱 Release 빌드 업데이트  
✅ 실제 기기/에뮬레이터에서 테스트  
✅ HTTPS 연결 정상 작동  

## 7. 문제해결

### 배포 실패 시
1. `gcloud auth login` 로그인 확인
2. 프로젝트 ID 확인
3. 필요한 API 활성화 확인
4. Docker 설치 및 실행 확인

### Android 연결 실패 시
1. Release 빌드로 변경했는지 확인
2. Cloud Run URL이 정확한지 확인
3. 인터넷 연결 확인
4. 네트워크 보안 설정 확인