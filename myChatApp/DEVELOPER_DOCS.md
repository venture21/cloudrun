# myChatApp 개발자 문서

## 프로젝트 개요
myChatApp은 Flask 기반의 실시간 채팅 애플리케이션으로, Google Cloud Run에 배포하도록 설계되었습니다. 

## 파일 구조

### 백엔드 파일

#### 1. main.py (Flask 애플리케이션)
- **역할**: 메인 애플리케이션 서버 파일
- **주요 기능**:
  - Flask 웹 서버 초기화
  - 메시지를 메모리에 저장 (리스트 사용)
  - 3개의 라우트 엔드포인트 제공

- **코드 분석**:
  ```python
  app = Flask(__name__)
  messages = []  # 메모리에 메시지 저장 (서버 재시작 시 초기화됨)
  ```

- **엔드포인트**:
  1. `GET /`: 메인 페이지 렌더링 (index.html 반환)
  2. `POST /send`: 메시지 전송 API
     - JSON 형식으로 메시지 수신
     - 메시지를 messages 리스트에 추가
     - 상태 코드 반환
  3. `GET /messages`: 모든 메시지 조회 API
     - 저장된 모든 메시지를 JSON 배열로 반환

#### 2. requirements.txt
- **역할**: Python 의존성 패키지 목록
- **패키지**:
  - `Flask`: 웹 프레임워크
  - `gunicorn`: WSGI HTTP 서버 (프로덕션 환경용)

#### 3. Dockerfile
- **역할**: Docker 컨테이너 이미지 빌드 설정
- **주요 내용**:
  - 베이스 이미지: Python 3.9-slim
  - 작업 디렉토리: /app
  - 의존성 설치 후 애플리케이션 코드 복사
  - Gunicorn을 통해 포트 8080으로 서비스 실행
  ```dockerfile
  CMD ["gunicorn", "--bind", "0.0.0.0:8080", "main:app"]
  ```

#### 4. cloudbuild.yaml
- **역할**: Google Cloud Build 자동 배포 설정
- **배포 프로세스**:
  1. Docker 이미지 빌드
  2. Google Container Registry에 이미지 푸시
  3. Cloud Run에 배포 (us-central1 리전)
  4. 인증 없이 접근 가능하도록 설정

### 프론트엔드 파일

#### 1. templates/index.html
- **역할**: 메인 채팅 UI 페이지
- **주요 기능**:
  - 메시지 표시 영역
  - 메시지 입력 필드 및 전송 버튼
  - JavaScript로 실시간 업데이트 구현

- **JavaScript 기능**:
  1. `fetchMessages()`: 
     - `/messages` API를 통해 메시지 목록 조회
     - DOM에 메시지 렌더링
  2. `sendMessage()`:
     - 입력된 메시지를 `/send` API로 전송
     - 전송 후 입력 필드 초기화 및 메시지 목록 갱신
  3. 이벤트 리스너:
     - Send 버튼 클릭 이벤트
     - Enter 키 입력 이벤트
  4. 자동 새로고침:
     - `setInterval`로 3초마다 메시지 목록 갱신

#### 2. static/style.css
- **역할**: 애플리케이션 스타일시트
- **디자인 특징**:
  - 중앙 정렬된 채팅 컨테이너 (400x600px)
  - 플렉스박스 레이아웃 사용
  - 심플한 흰색 배경의 채팅창
  - 파란색 전송 버튼
  - 메시지 영역에 스크롤 기능

## 기술 스택
- **백엔드**: Python, Flask, Gunicorn
- **프론트엔드**: HTML5, CSS3, Vanilla JavaScript
- **배포**: Docker, Google Cloud Run, Cloud Build
- **컨테이너 레지스트리**: Google Container Registry

## 보안 고려사항
- 현재 인증 없이 접근 가능 (`--allow-unauthenticated`)
- 메시지가 메모리에만 저장되어 서버 재시작 시 데이터 손실
- XSS 공격에 대한 보호 미구현 (innerHTML 사용)

## 개선 제안
1. 데이터베이스 연동으로 영구 메시지 저장
2. 사용자 인증 및 권한 관리
3. WebSocket을 통한 실시간 통신
4. XSS 방지를 위한 입력 검증 및 이스케이프 처리
5. 메시지 암호화