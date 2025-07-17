# Android Studio Narwhal 빌드 가이드

## 사전 요구사항

1. **Android Studio Narwhal (2025.1.x)** 설치
2. **JDK 17** 이상 설치
3. **Android SDK 35** 설치
4. Flask 서버가 실행 중이어야 함

## 빌드 과정

### 1. 프로젝트 열기

1. Android Studio를 실행합니다
2. **File > Open** 선택
3. `/home/park/cloudrun/VertexGeminiApp/android` 폴더 선택
4. **OK** 클릭

### 2. Gradle Sync

프로젝트를 열면 자동으로 Gradle sync가 시작됩니다. 만약 자동으로 시작되지 않으면:

1. 상단 알림바에서 **Sync Now** 클릭
2. 또는 **File > Sync Project with Gradle Files** 선택

### 3. SDK 설정 확인

1. **File > Project Structure** (Ctrl+Alt+Shift+S)
2. **SDK Location** 탭에서 Android SDK 경로 확인
3. **Modules** 탭에서 다음 설정 확인:
   - Compile SDK Version: 35
   - Target SDK Version: 35
   - Min SDK Version: 24

### 4. 서버 URL 설정

로컬 테스트를 위해 `ChatRepository.kt` 파일의 URL을 확인합니다:

```kotlin
// android/app/src/main/java/com/example/geminichat/ChatRepository.kt

// 에뮬레이터에서 테스트하는 경우
.baseUrl("http://10.0.2.2:8080/")

// 실제 디바이스에서 테스트하는 경우 (PC의 IP 주소로 변경)
.baseUrl("http://192.168.x.x:8080/")  // 예시
```

**PC의 IP 주소 확인 방법:**
- Windows: `ipconfig` 명령어
- Mac/Linux: `ifconfig` 또는 `ip addr` 명령어

### 5. 에뮬레이터 설정 (선택사항)

1. **Tools > AVD Manager** 선택
2. **Create Virtual Device** 클릭
3. 디바이스 선택 (예: Pixel 7)
4. System Image 선택 (API 35 권장)
5. AVD 이름 설정 후 **Finish**

### 6. 빌드 및 실행

#### 방법 1: Run 버튼 사용
1. 상단 툴바에서 디바이스 선택 (에뮬레이터 또는 연결된 실제 디바이스)
2. **Run** 버튼 클릭 (녹색 삼각형) 또는 Shift+F10

#### 방법 2: Gradle 명령어 사용
1. Android Studio 하단의 **Terminal** 탭 열기
2. 다음 명령어 실행:

```bash
# Debug APK 빌드
./gradlew assembleDebug

# Release APK 빌드
./gradlew assembleRelease

# 에뮬레이터/디바이스에 설치 및 실행
./gradlew installDebug
```

### 7. 빌드 결과 확인

빌드가 완료되면 APK 파일 위치:
- Debug: `app/build/outputs/apk/debug/app-debug.apk`
- Release: `app/build/outputs/apk/release/app-release.apk`

## 문제 해결

### Adaptive Icon 오류 해결
만약 `AAPT: error: <adaptive-icon> elements require a sdk version of at least 26` 오류가 발생하면:

1. **Android Studio에서 아이콘 생성:**
   - 프로젝트에서 `app` 모듈 우클릭
   - **New > Image Asset** 선택
   - Icon Type: **Launcher Icons (Adaptive and Legacy)**
   - Foreground Layer와 Background Layer 설정
   - **Next** > **Finish**

2. **또는 임시 해결책:**
   - `mipmap-anydpi-v26` 폴더에 adaptive icon XML 파일이 있는지 확인
   - 기본 mipmap 폴더들(mdpi, hdpi, xhdpi 등)이 존재하는지 확인

### Gradle sync 실패
1. **File > Invalidate Caches** 선택
2. **Invalidate and Restart** 클릭
3. Android Studio 재시작 후 다시 시도

### 빌드 오류
1. **Build > Clean Project** 실행
2. **Build > Rebuild Project** 실행

### 네트워크 연결 오류
1. Flask 서버가 실행 중인지 확인
2. 방화벽 설정 확인 (8080 포트 허용)
3. 에뮬레이터의 경우 `10.0.2.2` 주소 사용
4. 실제 디바이스의 경우 PC와 같은 네트워크에 연결되어 있는지 확인

### JDK 버전 문제
1. **File > Project Structure > SDK Location**
2. **JDK Location**에서 JDK 17 경로 설정
3. 또는 `JAVA_HOME` 환경변수 확인

## 테스트 방법

1. 앱이 실행되면 메시지 입력창에 텍스트 입력
2. 전송 버튼 클릭
3. Gemini AI의 응답 확인
4. 각 메시지에 타임스탬프가 표시되는지 확인

## APK 서명 (Release 빌드)

Release APK를 생성하려면:

1. **Build > Generate Signed Bundle / APK**
2. **APK** 선택
3. Key store 생성 또는 기존 키 사용
4. 서명 정보 입력
5. Build variant에서 **release** 선택
6. **Finish** 클릭

## Cloud Run 배포 후 설정

서버가 Cloud Run에 배포된 후:

1. `ChatRepository.kt`의 baseUrl을 Cloud Run URL로 변경:
```kotlin
.baseUrl("https://flask-chat-app-xxxxx-an.a.run.app/")
```

2. 앱을 다시 빌드하여 배포

## 추가 팁

- **Instant Run** 기능을 사용하면 코드 변경사항을 빠르게 테스트 가능
- **Layout Inspector**로 UI 디버깅 가능 (View > Tool Windows > Layout Inspector)
- **Profiler**로 성능 모니터링 가능 (View > Tool Windows > Profiler)
- Logcat에서 네트워크 요청/응답 로그 확인 가능