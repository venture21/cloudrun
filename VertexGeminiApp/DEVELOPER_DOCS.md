# Vertex AI Gemini Chat App - 개발자 문서

이 문서는 Vertex AI Gemini Chat App의 전체 아키텍처와 각 컴포넌트의 세부 구현 내용을 설명합니다.

## 프로젝트 아키텍처 개요

```
VertexGeminiApp/
├── 백엔드 (Flask Python API)
│   ├── app.py                    # 메인 Flask 애플리케이션
│   ├── requirements.txt          # Python 의존성
│   ├── Dockerfile               # 컨테이너 빌드 설정
│   └── 스크립트 파일들
├── Android 앱 (Kotlin)
│   └── android/
│       └── app/src/main/java/com/example/geminichat/
└── iOS 앱 (Swift/SwiftUI)
    └── ios/GeminiChat/GeminiChat/
```

---

## 1. 백엔드 (Flask API)

### 1.1 메인 애플리케이션 (`app.py`)

**역할**: Vertex AI Gemini API와 연동하는 Flask 웹 서버

**주요 기능**:
- Vertex AI Gemini 2.5-flash 모델과의 연동
- 세션별 채팅 히스토리 관리
- CORS 지원으로 모바일 앱과의 통신

**핵심 코드 분석**:

```python
# Vertex AI 초기화
PROJECT_ID = os.environ.get('PROJECT_ID', 'sesac-dev-400904')
LOCATION = os.environ.get('LOCATION', 'us-central1')
vertexai.init(project=PROJECT_ID, location=LOCATION)
model = GenerativeModel("gemini-2.5-flash")
```

**API 엔드포인트**:

1. **`/health` (GET)**: 서버 상태 확인
   - 반환: `{"status": "healthy"}`

2. **`/chat` (POST)**: 채팅 메시지 전송
   ```python
   # 요청 형식
   {
     "message": "사용자 메시지",
     "session_id": "세션 ID (선택적)"
   }
   
   # 응답 형식
   {
     "response": "AI 응답",
     "timestamp": "2024-01-01 12:00:00",
     "session_id": "세션 ID"
   }
   ```

3. **`/chat/reset` (POST)**: 채팅 세션 초기화
   ```python
   # 요청 형식
   {
     "session_id": "리셋할 세션 ID"
   }
   ```

**세션 관리**:
- 메모리 기반 세션 저장 (`chat_sessions = {}`)
- 세션별로 독립적인 채팅 컨텍스트 유지
- 프로덕션 환경에서는 Redis 등 외부 저장소 권장

### 1.2 의존성 관리 (`requirements.txt`)

```
Flask==3.0.0              # 웹 프레임워크
flask-cors==4.0.0         # CORS 지원
google-cloud-aiplatform==1.60.0  # Google Cloud AI Platform SDK
vertexai==1.60.0          # Vertex AI SDK
pytz==2024.1              # 시간대 처리
gunicorn==21.2.0          # WSGI 서버
```

### 1.3 컨테이너화 (`Dockerfile`)

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
ENV PYTHONUNBUFFERED=1
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 app:app
```

**설정 포인트**:
- Python 3.11 슬림 이미지 사용
- Gunicorn으로 프로덕션 배포
- 단일 워커, 8 스레드로 동시성 처리

### 1.4 배포 스크립트들

#### `deploy.sh`
**역할**: Cloud Run 자동 배포 스크립트

**주요 기능**:
- Google Cloud API 활성화
- Docker 이미지 빌드 및 푸시
- Cloud Run 서비스 배포
- 환경변수 설정

#### `test_server.py`
**역할**: 로컬 서버 테스트 도구

**테스트 시나리오**:
- Health check API 테스트
- Chat API 기본 동작 테스트
- 한국어 메시지 테스트

#### `start_local_server.sh`
**역할**: 로컬 개발 환경 시작 스크립트

**설정**:
- Android 에뮬레이터 지원 (`10.0.2.2:8080`)
- 개발 모드 환경변수 설정
- 디버그 모드 활성화

---

## 2. Android 앱 (Kotlin)

### 2.1 아키텍처 패턴
- **MVVM (Model-View-ViewModel)** 패턴 사용
- **Repository Pattern**으로 데이터 레이어 분리
- **Retrofit**을 통한 HTTP 통신
- **Coroutines**를 이용한 비동기 처리

### 2.2 핵심 컴포넌트

#### `MainActivity.kt`
**역할**: 메인 액티비티, UI 컨트롤러

**주요 기능**:
```kotlin
class MainActivity : AppCompatActivity() {
    private lateinit var viewModel: ChatViewModel
    private lateinit var adapter: ChatAdapter
    
    // UI 요소들
    private lateinit var recyclerView: RecyclerView
    private lateinit var messageInput: EditText
    private lateinit var sendButton: ImageButton
    private lateinit var connectionStatus: TextView
}
```

**UI 상태 관리**:
- `viewModel.messages.observe()`: 메시지 목록 업데이트
- `viewModel.isLoading.observe()`: 로딩 상태에 따른 버튼 비활성화
- `viewModel.connectionError.observe()`: 연결 오류 표시

#### `ChatViewModel.kt`
**역할**: 비즈니스 로직 및 상태 관리

**핵심 구현**:
```kotlin
class ChatViewModel : ViewModel() {
    private val repository = ChatRepository()
    private val sessionId = UUID.randomUUID().toString()
    
    private val _messages = MutableLiveData<List<ChatMessage>>(emptyList())
    val messages: LiveData<List<ChatMessage>> = _messages
    
    fun sendMessage(content: String) {
        viewModelScope.launch {
            // 사용자 메시지 즉시 추가
            val userMessage = ChatMessage(content, true, System.currentTimeMillis())
            addMessage(userMessage)
            
            try {
                // API 호출 및 응답 처리
                val response = repository.sendMessage(content, sessionId)
                val botMessage = ChatMessage(response.response, false, System.currentTimeMillis())
                addMessage(botMessage)
            } catch (e: Exception) {
                // 오류 처리
                _connectionError.value = e.message
            }
        }
    }
}
```

#### `ChatRepository.kt`
**역할**: 네트워크 통신 레이어

**Retrofit 설정**:
```kotlin
class ChatRepository {
    init {
        val client = OkHttpClient.Builder()
            .addInterceptor(HttpLoggingInterceptor().apply { 
                level = HttpLoggingInterceptor.Level.BODY 
            })
            .connectTimeout(30, TimeUnit.SECONDS)
            .build()
        
        val retrofit = Retrofit.Builder()
            .baseUrl(BuildConfig.API_BASE_URL)
            .client(client)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
    }
}
```

**API 인터페이스**:
```kotlin
interface ChatApiService {
    @POST("/chat")
    suspend fun sendMessage(@Body request: ChatRequest): ChatResponse
    
    @POST("/chat/reset") 
    suspend fun resetChat(@Body request: ResetRequest)
}
```

#### `ChatAdapter.kt`
**역할**: RecyclerView 어댑터, 메시지 목록 표시

**ViewHolder 패턴**:
```kotlin
class ChatAdapter : ListAdapter<ChatMessage, ChatAdapter.ChatViewHolder>(ChatDiffCallback()) {
    override fun getItemViewType(position: Int): Int {
        return if (getItem(position).isUser) VIEW_TYPE_USER else VIEW_TYPE_BOT
    }
    
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ChatViewHolder {
        val layoutId = if (viewType == VIEW_TYPE_USER) {
            R.layout.item_message_user
        } else {
            R.layout.item_message_bot
        }
        return ChatViewHolder(LayoutInflater.from(parent.context).inflate(layoutId, parent, false))
    }
}
```

#### `ChatMessage.kt`
**역할**: 메시지 데이터 모델

```kotlin
data class ChatMessage(
    val content: String,
    val isUser: Boolean,
    val timestamp: Long,
    val formattedTime: String? = null
) {
    fun getDisplayTime(): String {
        return formattedTime ?: SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
            .format(Date(timestamp))
    }
}
```

### 2.3 빌드 설정 (`build.gradle`)

**핵심 의존성**:
```gradle
dependencies {
    // Android 기본
    implementation 'androidx.core:core-ktx:1.15.0'
    implementation 'androidx.lifecycle:lifecycle-viewmodel-ktx:2.8.7'
    
    // 네트워킹
    implementation 'com.squareup.retrofit2:retrofit:2.11.0'
    implementation 'com.squareup.retrofit2:converter-gson:2.11.0'
    implementation 'com.squareup.okhttp3:logging-interceptor:4.12.0'
    
    // 코루틴
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.9.0'
}
```

**빌드 타입별 설정**:
```gradle
buildTypes {
    debug {
        buildConfigField "String", "API_BASE_URL", '"https://flask-chat-app-902882112756.us-central1.run.app"'
    }
    release {
        buildConfigField "String", "API_BASE_URL", '"https://flask-chat-app-902882112756.us-central1.run.app"'
    }
}
```

---

## 3. iOS 앱 (Swift/SwiftUI)

### 3.1 아키텍처 패턴
- **MVVM 패턴** with SwiftUI
- **Combine 프레임워크**를 통한 반응형 프로그래밍
- **URLSession**을 이용한 HTTP 통신

### 3.2 핵심 컴포넌트

#### `GeminiChatApp.swift`
**역할**: 앱 진입점

```swift
@main
struct GeminiChatApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
    }
}
```

#### `ContentView.swift`
**역할**: 메인 UI 뷰

**SwiftUI 구성**:
```swift
struct ContentView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var messageText = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // 연결 오류 배너
            if let error = viewModel.connectionError {
                Text("Connection error: \(error)")
                    .foregroundColor(.red)
                    .background(Color.yellow.opacity(0.2))
            }
            
            // 채팅 메시지 목록
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MessageView(message: message)
                                .id(message.id)
                        }
                    }
                }
                .onChange(of: viewModel.messages.count) { _ in
                    withAnimation {
                        proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                    }
                }
            }
            
            // 입력 영역
            HStack(spacing: 12) {
                TextField("Type a message...", text: $messageText)
                    .onSubmit { sendMessage() }
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .frame(width: 44, height: 44)
                        .background(viewModel.isLoading ? Color.gray : Color.blue)
                        .clipShape(Circle())
                }
                .disabled(viewModel.isLoading || messageText.isEmpty)
            }
        }
    }
}
```

**MessageView 컴포넌트**:
```swift
struct MessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            VStack(alignment: message.isUser ? .trailing : .leading) {
                Text(message.content)
                    .padding(12)
                    .foregroundColor(message.isUser ? .white : .primary)
                    .background(message.isUser ? Color.blue : Color(.systemGray5))
                    .cornerRadius(16)
                
                Text(message.displayTime)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !message.isUser { Spacer() }
        }
    }
}
```

#### `ChatViewModel.swift`
**역할**: 상태 관리 및 비즈니스 로직

**Combine을 이용한 반응형 프로그래밍**:
```swift
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var connectionError: String?
    
    private let chatService = ChatService()
    private let sessionId = UUID().uuidString
    private var cancellables = Set<AnyCancellable>()
    
    func sendMessage(_ content: String) {
        isLoading = true
        connectionError = nil
        
        // 사용자 메시지 즉시 추가
        let userMessage = ChatMessage(content: content, isUser: true, timestamp: Date())
        messages.append(userMessage)
        
        // API 호출
        chatService.sendMessage(content, sessionId: sessionId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.connectionError = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] response in
                    let botMessage = ChatMessage(
                        content: response.response,
                        isUser: false,
                        timestamp: Date(),
                        formattedTime: response.timestamp
                    )
                    self?.messages.append(botMessage)
                }
            )
            .store(in: &cancellables)
    }
}
```

#### `ChatService.swift`
**역할**: 네트워크 통신 서비스

**URLSession 기반 HTTP 클라이언트**:
```swift
class ChatService {
    private let baseURL: String
    private let session: URLSession
    
    init() {
        #if targetEnvironment(simulator)
        self.baseURL = "http://localhost:8080"
        #else
        self.baseURL = "http://localhost:8080" // 실제 기기용 IP 설정 필요
        #endif
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }
    
    func sendMessage(_ message: String, sessionId: String) -> AnyPublisher<ChatResponse, Error> {
        guard let url = URL(string: "\(baseURL)/chat") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let chatRequest = ChatRequest(message: message, session_id: sessionId)
        request.httpBody = try? JSONEncoder().encode(chatRequest)
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: ChatResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
```

#### `ChatMessage.swift`
**역할**: 메시지 데이터 모델

```swift
struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    var formattedTime: String?
    
    var displayTime: String {
        if let formattedTime = formattedTime {
            return formattedTime
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter.string(from: timestamp)
    }
}
```

---

## 4. 주요 기술적 특징

### 4.1 세션 관리
- **세션 ID**: UUID를 통한 고유 세션 식별
- **컨텍스트 유지**: 대화 히스토리를 통한 연속적인 대화
- **멀티 세션**: 여러 클라이언트의 독립적인 세션 지원

### 4.2 오류 처리
- **네트워크 오류**: 연결 실패, 타임아웃 처리
- **API 오류**: 잘못된 요청, 서버 오류 처리
- **사용자 피드백**: 오류 메시지 표시 및 재시도 기능

### 4.3 성능 최적화
- **비동기 처리**: Coroutines(Android), Combine(iOS)를 통한 논블로킹 처리
- **메모리 관리**: RecyclerView(Android), LazyVStack(iOS)를 통한 효율적인 리스트 처리
- **이미지 최적화**: 벡터 아이콘 사용으로 다양한 화면 밀도 지원

### 4.4 개발자 도구
- **로깅**: HTTP 요청/응답 로깅을 통한 디버깅 지원
- **테스트 스크립트**: 자동화된 API 테스트 도구
- **배포 스크립트**: 원클릭 Cloud Run 배포

---

## 5. 확장 가능성

### 5.1 데이터베이스 연동
현재 메모리 기반 세션 저장을 다음으로 확장 가능:
- **Redis**: 세션 저장 및 캐싱
- **PostgreSQL/MySQL**: 사용자 관리 및 채팅 히스토리
- **Firestore**: 실시간 동기화 및 오프라인 지원

### 5.2 인증 시스템
- **Firebase Auth**: 소셜 로그인 지원
- **JWT**: 토큰 기반 인증
- **OAuth 2.0**: 외부 서비스 연동

### 5.3 실시간 기능
- **WebSocket**: 실시간 메시지 전송
- **Server-Sent Events**: 실시간 알림
- **Push Notification**: 모바일 푸시 알림

### 5.4 AI 기능 확장
- **멀티모달**: 이미지, 음성 입력 지원
- **프롬프트 엔지니어링**: 도메인별 특화 모델
- **RAG (Retrieval Augmented Generation)**: 외부 지식 베이스 연동

이 개발자 문서는 프로젝트의 전체 구조와 각 컴포넌트의 역할을 상세히 설명하여, 새로운 개발자가 프로젝트에 빠르게 참여할 수 있도록 돕습니다.