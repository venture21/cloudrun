# myGemini 개발자 문서

## 프로젝트 개요
myGemini는 Google Gemini AI API를 활용한 웹 기반 챗봇 애플리케이션입니다. Flask 프레임워크로 구축된 백엔드와 순수 JavaScript로 구현된 프론트엔드로 구성되어 있으며, Google Cloud Run에 배포 가능하도록 설계되었습니다.

## 기술 스택
- **백엔드**: Python 3.11, Flask 3.0.0
- **AI 모델**: Google Gemini 2.5 Flash
- **배포**: Docker, Google Cloud Run
- **웹 서버**: Gunicorn

## 프로젝트 구조

```
myGemini/
├── app.py              # Flask 백엔드 서버
├── requirements.txt    # Python 의존성 패키지
├── Dockerfile         # Docker 컨테이너 설정
├── templates/
│   └── index.html     # 프론트엔드 HTML/CSS/JS
├── test_local.sh      # 로컬 테스트 스크립트
└── README.md          # 프로젝트 문서
```

## 백엔드 파일 분석

### 1. app.py (메인 서버 파일)

#### 주요 기능:
- Flask 웹 서버 초기화 및 라우트 설정
- Google Gemini AI와의 통신 관리
- 대화 컨텍스트 유지 및 관리
- CORS 설정으로 크로스 오리진 요청 허용

#### 코드 구조:

##### 초기화 부분 (1-26줄):
```python
import os
from flask import Flask, render_template, request, jsonify
import google.generativeai as genai
from flask_cors import CORS
from dotenv import load_dotenv
```
- 필요한 라이브러리 임포트
- `.env` 파일에서 환경 변수 로드
- Flask 앱과 CORS 초기화
- Google API 키 검증 및 설정
- Gemini 2.5 Flash 모델 초기화

##### 라우트 정의:

1. **`/` (27-29줄)**: 메인 페이지 라우트
   - `index.html` 템플릿 렌더링

2. **`/chat` (31-61줄)**: 채팅 API 엔드포인트
   - POST 메서드로 사용자 메시지 수신
   - 대화 기록에 메시지 추가 (최근 10개 유지)
   - Gemini 모델에 컨텍스트와 함께 요청
   - JSON 형식으로 응답 반환
   - 에러 처리 및 상태 코드 관리

3. **`/clear` (63-67줄)**: 대화 초기화 엔드포인트
   - POST 메서드로 대화 기록 초기화
   - 전역 변수 `conversation_history` 리셋

##### 서버 실행 부분 (69-72줄):
- Cloud Run 환경에서 PORT 환경 변수 사용
- 기본 포트 8080으로 설정
- 모든 IP에서 접근 가능하도록 host='0.0.0.0' 설정

### 2. requirements.txt (의존성 파일)

각 패키지의 역할:
- **Flask==3.0.0**: 웹 프레임워크
- **flask-cors==4.0.0**: Cross-Origin Resource Sharing 지원
- **google-generativeai==0.8.3**: Google Gemini AI API 클라이언트
- **gunicorn==21.2.0**: 프로덕션 환경용 WSGI 서버
- **python-dotenv==1.0.0**: 환경 변수 관리

### 3. Dockerfile (컨테이너 설정)

#### 구성 요소:
- **베이스 이미지**: Python 3.11 slim (경량화 버전)
- **작업 디렉토리**: `/app`
- **시스템 패키지**: 최신 버전으로 업데이트
- **Python 패키지**: requirements.txt 기반 설치
- **환경 변수**: `PYTHONUNBUFFERED=1` (실시간 로그 출력)
- **포트**: 8080 (Cloud Run 기본값)
- **실행 명령**: Gunicorn으로 멀티스레드 실행
  - Workers: 1개
  - Threads: 8개
  - Timeout: 300초

### 4. test_local.sh (로컬 테스트 스크립트)

#### 기능:
1. Google API 키 환경 변수 확인
2. Python 가상환경 생성 및 활성화
3. 의존성 패키지 설치
4. Flask 개발 서버 실행

#### 사용 방법:
```bash
chmod +x test_local.sh
./test_local.sh
```

## 프론트엔드 파일 분석

### templates/index.html

#### 구조:
단일 HTML 파일에 CSS와 JavaScript가 내장된 SPA (Single Page Application)

#### 주요 구성 요소:

##### 1. HTML 구조 (1-236줄):
- **헤더**: 애플리케이션 제목과 대화 초기화 버튼
- **메시지 영역**: 채팅 메시지 표시 공간
- **타이핑 인디케이터**: AI 응답 대기 시 표시
- **입력 폼**: 메시지 입력창과 전송 버튼

##### 2. CSS 스타일 (7-196줄):
- **반응형 디자인**: 최대 너비 600px
- **모던 UI**: 
  - 둥근 모서리와 그림자 효과
  - 부드러운 애니메이션 (fadeIn, typing)
  - 사용자/봇 메시지 구분 스타일
- **색상 테마**:
  - 주 색상: #2196F3 (파란색)
  - 배경색: #f0f2f5
  - 메시지 버블: 사용자(파란색), AI(회색)

##### 3. JavaScript 기능 (237-360줄):

**주요 함수:**

1. **`addMessage(content, isUser)`** (244-261줄):
   - 새 메시지를 채팅창에 추가
   - 사용자/AI 구분하여 스타일 적용
   - 자동 스크롤 처리

2. **`showTypingIndicator()`/`hideTypingIndicator()`** (263-270줄):
   - AI 응답 대기 중 타이핑 애니메이션 표시/숨김

3. **`showError(message)`** (272-282줄):
   - 에러 메시지 표시 (5초 후 자동 제거)

4. **`sendMessage(message)`** (284-314줄):
   - 서버에 POST 요청으로 메시지 전송
   - 비동기 처리 (async/await)
   - 에러 핸들링 및 UI 상태 관리

5. **`clearChat()`** (316-335줄):
   - 사용자 확인 후 대화 기록 초기화
   - 서버의 `/clear` 엔드포인트 호출

**이벤트 리스너:**
- 폼 제출 이벤트 (337-347줄)
- Enter 키 전송 지원 (350-355줄)
- 페이지 로드 시 자동 포커스 (358줄)

## API 엔드포인트 명세

### 1. GET `/`
- **설명**: 메인 페이지 반환
- **응답**: HTML 페이지

### 2. POST `/chat`
- **설명**: 사용자 메시지 처리 및 AI 응답 생성
- **요청 본문**:
  ```json
  {
    "message": "사용자 메시지"
  }
  ```
- **성공 응답** (200):
  ```json
  {
    "response": "AI 응답 메시지",
    "status": "success"
  }
  ```
- **에러 응답** (400/500):
  ```json
  {
    "error": "에러 메시지",
    "status": "error"
  }
  ```

### 3. POST `/clear`
- **설명**: 대화 기록 초기화
- **응답**:
  ```json
  {
    "status": "success",
    "message": "대화 기록이 초기화되었습니다."
  }
  ```

## 보안 고려사항

1. **API 키 관리**:
   - 환경 변수로 관리 (코드에 하드코딩 금지)
   - `.env` 파일은 `.gitignore`에 추가
   - 프로덕션에서는 Secret Manager 사용 권장

2. **CORS 설정**:
   - 현재 모든 도메인 허용 상태
   - 프로덕션에서는 특정 도메인만 허용하도록 수정 필요

3. **입력 검증**:
   - 빈 메시지 검증 구현
   - XSS 방지를 위해 `textContent` 사용

## 성능 최적화

1. **대화 기록 관리**:
   - 최근 10개 메시지만 유지하여 메모리 사용량 제한
   - 컨텍스트 크기 제한으로 API 비용 절감

2. **서버 설정**:
   - Gunicorn 멀티스레드 설정 (8 threads)
   - 300초 타임아웃으로 긴 대화 지원

3. **프론트엔드 최적화**:
   - 단일 HTML 파일로 추가 요청 최소화
   - CSS/JS 인라인으로 로딩 시간 단축

## 배포 고려사항

1. **Cloud Run 최적화**:
   - 콜드 스타트 최소화를 위한 경량 이미지 사용
   - 환경 변수로 포트 설정 유연성 확보

2. **확장성**:
   - 상태 비저장 설계로 수평 확장 가능
   - 대화 기록을 메모리에 저장하므로 인스턴스 간 공유 불가
   - 필요시 Redis 등 외부 저장소 고려

3. **모니터링**:
   - Cloud Logging으로 로그 확인
   - 에러 추적 및 성능 모니터링 설정 권장

## 개발 가이드

### 로컬 개발 환경 설정:
1. Python 3.11 설치
2. 가상환경 생성 및 활성화
3. `pip install -r requirements.txt`
4. `.env` 파일에 `GOOGLE_API_KEY` 설정
5. `python app.py` 또는 `./test_local.sh` 실행

### 기능 추가 시 고려사항:
1. 새 엔드포인트는 app.py에 추가
2. UI 변경은 index.html에서 처리
3. 대화 기록 영구 저장이 필요한 경우 데이터베이스 연동 필요
4. 멀티 세션 지원을 위해서는 세션 관리 시스템 구현 필요

### 테스트:
- 단위 테스트 프레임워크 추가 권장 (pytest)
- API 엔드포인트 테스트
- 프론트엔드 JavaScript 테스트 (Jest)

## 트러블슈팅

### 일반적인 문제:
1. **API 키 오류**: 환경 변수 확인
2. **CORS 에러**: flask-cors 설정 확인
3. **타임아웃**: Gunicorn timeout 값 조정
4. **메모리 부족**: Cloud Run 메모리 할당 증가

### 디버깅 팁:
- 로컬에서 `debug=True` 설정으로 상세 에러 확인
- Cloud Run 로그에서 실시간 로그 모니터링
- 브라우저 개발자 도구에서 네트워크 요청 확인