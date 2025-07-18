# myVertexGemini 개발자 문서

## 프로젝트 개요
이 프로젝트는 Google Vertex AI의 Gemini 2.5 Flash 모델을 사용하여 채팅 애플리케이션을 구현한 Flask 기반 웹 애플리케이션입니다.

## 프로젝트 구조

### 백엔드 파일

#### 1. `app.py` (메인 Flask 애플리케이션)
- **역할**: Flask 웹 서버의 핵심 파일로, API 엔드포인트와 라우팅을 관리
- **주요 기능**:
  - Vertex AI 초기화 (프로젝트 ID: sesac-dev-400904, 리전: us-central1)
  - Gemini 2.5 Flash 모델 로드 및 채팅 세션 관리
  - 두 개의 라우트 제공:
    - `/` (GET): 메인 페이지 렌더링
    - `/chat` (POST): 사용자 메시지를 받아 AI 응답 생성
  - 스트리밍 방식으로 AI 응답 처리
  - 에러 핸들링 구현

#### 2. `gemini-example.py` (독립 실행형 채팅 예제)
- **역할**: 커맨드라인 기반 Gemini 채팅봇 예제
- **주요 기능**:
  - Vertex AI 초기화 및 Gemini 2.5 Flash 모델 설정
  - 콘솔 기반 대화형 채팅 인터페이스
  - 실시간 스트리밍 응답 출력
  - '종료' 명령어로 프로그램 종료
  - 상세한 한국어 주석으로 코드 설명
  - Generation Config 설정:
    - max_output_tokens: 8192
    - temperature: 0.9 (높은 창의성)
    - top_p: 1.0
    - top_k: 32

#### 3. `requirements.txt` (의존성 관리)
- **역할**: Python 패키지 의존성 정의
- **포함된 패키지**:
  - `flask`: 웹 프레임워크
  - `google-cloud-aiplatform`: Vertex AI SDK

#### 4. `Dockerfile` (컨테이너화 설정)
- **역할**: Docker 이미지 빌드 설정
- **주요 설정**:
  - Python 3.9 slim 이미지 사용
  - 작업 디렉토리: /app
  - 포트 8080 노출
  - app.py 실행

### 프론트엔드 파일

#### 1. `templates/index.html` (메인 UI)
- **역할**: 채팅 인터페이스 HTML 템플릿
- **주요 기능**:
  - 반응형 채팅 UI 제공
  - 채팅 히스토리 표시 (스크롤 가능)
  - 사용자 입력 폼
  - JavaScript로 비동기 통신 구현
- **UI 구성요소**:
  - 채팅 컨테이너 (400px 너비)
  - 채팅 히스토리 영역 (300px 높이, 스크롤)
  - 입력 필드와 전송 버튼
- **JavaScript 기능**:
  - 폼 제출 시 AJAX 요청
  - 메시지 추가 및 스크롤 자동 조정
  - JSON 형식으로 서버와 통신

## API 엔드포인트

### 1. GET `/`
- **설명**: 메인 채팅 페이지 렌더링
- **응답**: HTML 페이지

### 2. POST `/chat`
- **설명**: 사용자 메시지를 받아 AI 응답 생성
- **요청 형식**:
  ```json
  {
    "message": "사용자 메시지"
  }
  ```
- **응답**: AI가 생성한 텍스트 응답
- **에러 처리**:
  - 400: 메시지가 없는 경우
  - 500: 서버 내부 오류

## 실행 방법

### 로컬 실행
```bash
# 의존성 설치
pip install -r requirements.txt

# Flask 앱 실행
python app.py
```

### Docker 실행
```bash
# 이미지 빌드
docker build -t myvertexgemini .

# 컨테이너 실행
docker run -p 8080:8080 myvertexgemini
```

### 독립 예제 실행
```bash
python gemini-example.py
```

## 환경 설정
- **프로젝트 ID**: sesac-dev-400904
- **리전**: us-central1
- **포트**: 8080
- **디버그 모드**: 활성화 (프로덕션에서는 비활성화 권장)

## 보안 고려사항
- 프로젝트 ID가 하드코딩되어 있음 (환경 변수 사용 권장)
- 디버그 모드가 활성화되어 있음 (프로덕션에서는 비활성화 필요)
- CORS 설정이 없음 (필요시 추가)