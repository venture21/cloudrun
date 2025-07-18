# Flask 채팅 애플리케이션 개발자 문서

## 프로젝트 개요
Flask와 Socket.IO를 사용한 실시간 채팅 애플리케이션으로, Google Cloud Run에서 실행되도록 설계되었습니다.

## 파일 구조 및 역할

### 백엔드 파일

#### 1. `app.py` (메인 애플리케이션)
- **역할**: Flask 서버와 Socket.IO 실시간 통신을 관리하는 핵심 백엔드 파일
- **주요 기능**:
  - Flask 애플리케이션 초기화 및 설정
  - Socket.IO 서버 구성 (CORS 허용, threading 모드)
  - 메시지 저장소 관리 (메모리 기반, 최대 100개 메시지)
  
- **라우트 및 이벤트 핸들러**:
  - `@app.route('/')`: 메인 페이지 렌더링
  - `@socketio.on('connect')`: 클라이언트 연결 시 이전 메시지 전송
  - `@socketio.on('disconnect')`: 클라이언트 연결 해제 처리
  - `@socketio.on('message')`: 메시지 수신 및 브로드캐스트
  - `@socketio.on('user_typing')`: 타이핑 상태 브로드캐스트

- **데이터 구조**:
  ```python
  message_data = {
      'username': str,      # 사용자 이름 (기본값: 'Anonymous')
      'message': str,       # 메시지 내용
      'timestamp': str      # 시간 (HH:MM:SS 형식)
  }
  ```

#### 2. `requirements.txt` (의존성 관리)
- **역할**: Python 패키지 의존성 정의
- **주요 패키지**:
  - `Flask==3.0.0`: 웹 프레임워크
  - `flask-socketio==5.3.6`: Flask용 Socket.IO 통합
  - `python-socketio==5.10.0`: Socket.IO 서버 구현
  - `eventlet==0.33.3`: 비동기 네트워킹 라이브러리
  - `gunicorn==21.2.0`: WSGI HTTP 서버 (프로덕션용)

#### 3. `Dockerfile` (컨테이너 설정)
- **역할**: Docker 이미지 빌드 설정
- **구성**:
  - Python 3.11 slim 이미지 기반
  - 작업 디렉토리: `/app`
  - 포트: 8080 (환경변수로 설정)
  - 실행 명령: Gunicorn (1 워커, 8 스레드)

### 프론트엔드 파일

#### 1. `templates/index.html` (메인 페이지)
- **역할**: 채팅 애플리케이션의 HTML 구조 정의
- **주요 구성요소**:
  - 채팅 헤더: 제목과 타이핑 표시기
  - 메시지 영역: 채팅 메시지 표시
  - 입력 영역: 사용자명 입력, 메시지 입력, 전송 버튼
- **외부 라이브러리**:
  - Socket.IO 클라이언트 (CDN)

#### 2. `static/js/chat.js` (클라이언트 JavaScript)
- **역할**: 클라이언트 측 실시간 통신 및 UI 상호작용 관리
- **주요 기능**:
  
  **Socket.IO 이벤트 리스너**:
  - `connect`: 서버 연결 확인
  - `previous_messages`: 이전 메시지 표시
  - `message`: 새 메시지 수신 및 표시
  - `user_typing`: 타이핑 상태 표시

  **핵심 함수**:
  - `sendMessage()`: 메시지 전송 처리
  - `displayMessage(data)`: 메시지 DOM 생성 및 표시
  - `scrollToBottom()`: 자동 스크롤
  - `startTyping()` / `stopTyping()`: 타이핑 상태 관리

  **이벤트 처리**:
  - Enter 키로 메시지 전송
  - 타이핑 시 실시간 상태 전송 (1초 디바운스)

#### 3. `static/css/style.css` (스타일시트)
- **역할**: 애플리케이션의 전체적인 디자인 및 레이아웃 정의
- **주요 스타일링**:
  
  **레이아웃**:
  - Flexbox 기반 중앙 정렬
  - 최대 너비 600px의 반응형 디자인
  - 높이 80vh의 채팅 컨테이너

  **컴포넌트 스타일**:
  - `.chat-header`: 파란색 배경 (#4a76a8)
  - `.chat-messages`: 스크롤 가능한 메시지 영역
  - `.message`: 개별 메시지 스타일 (그림자 효과)
  - `.chat-input-container`: 입력 영역 스타일

  **인터랙션**:
  - 버튼 호버 효과
  - 부드러운 전환 효과 (0.3초)

## 시스템 아키텍처

### 통신 흐름
1. **클라이언트 연결**: 페이지 로드 시 Socket.IO 연결 수립
2. **메시지 전송**: 
   - 클라이언트 → 서버: `socket.emit('message', data)`
   - 서버 → 모든 클라이언트: `emit('message', data, broadcast=True)`
3. **타이핑 표시**: 
   - 실시간 타이핑 상태 브로드캐스트
   - 자기 자신 제외 (`include_self=False`)

### 데이터 저장
- **현재**: 메모리 기반 리스트 (서버 재시작 시 초기화)
- **제한사항**: 최대 100개 메시지 (FIFO 방식)
- **프로덕션 권장사항**: Redis 또는 데이터베이스 사용

## 보안 고려사항
1. **SECRET_KEY**: 환경변수로 관리 (기본값 사용 금지)
2. **CORS**: 모든 origin 허용 (프로덕션에서는 제한 필요)
3. **입력 검증**: 현재 클라이언트 측 trim()만 적용
4. **XSS 방지**: innerHTML 사용 시 주의 필요

## 배포 고려사항
1. **Cloud Run 제한사항**: 
   - WebSocket 미지원 → HTTP long-polling 폴백
   - 인스턴스 간 상태 공유 불가
2. **스케일링**: 
   - 다중 인스턴스 시 Redis 필요
   - 세션 어피니티 설정 권장

## 개선 제안
1. 사용자 인증 시스템 추가
2. 메시지 영구 저장소 구현
3. 파일 업로드 기능
4. 이모지 지원
5. 메시지 수정/삭제 기능
6. 프라이빗 채팅룸 기능