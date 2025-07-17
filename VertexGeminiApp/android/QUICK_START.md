# Android 앱 빠른 시작 가이드

## 1. Flask 서버 실행 (터미널 1)
```bash
cd /home/park/cloudrun/VertexGeminiApp
python app.py
```

## 2. Android Studio에서 프로젝트 열기
- Android Studio 실행
- Open > `/home/park/cloudrun/VertexGeminiApp/android` 선택

## 3. 빠른 실행 (에뮬레이터)
1. AVD Manager에서 에뮬레이터 시작
2. Run 버튼 클릭 (Shift+F10)

## 4. 빠른 실행 (실제 디바이스)
1. 개발자 옵션 활성화
2. USB 디버깅 활성화
3. USB로 연결
4. `ChatRepository.kt`에서 URL 수정:
   ```kotlin
   .baseUrl("http://YOUR_PC_IP:8080/")  // 예: http://192.168.1.100:8080/
   ```
5. Run 버튼 클릭

## 5. 테스트
- 메시지 입력: "안녕하세요"
- 전송 버튼 클릭
- AI 응답 확인

## 일반적인 문제 해결

### Adaptive Icon 오류
```
Android Studio에서:
1. app 모듈 우클릭
2. New > Image Asset
3. Icon Type: Launcher Icons (Adaptive and Legacy)
4. 기본 설정으로 진행
5. Finish
```

### "Connection failed" 오류
```bash
# PC의 IP 주소 확인
ipconfig  # Windows
ifconfig  # Mac/Linux

# 방화벽에서 8080 포트 허용
# Windows: Windows Defender 방화벽 > 인바운드 규칙 > 새 규칙 > 포트 8080 허용
```

### Gradle sync 실패
```bash
# 프로젝트 디렉토리에서
./gradlew clean
./gradlew build
```

### 앱이 충돌하는 경우
- Logcat 확인: View > Tool Windows > Logcat
- 필터: "com.example.geminichat"