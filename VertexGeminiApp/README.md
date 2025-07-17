# Gemini Chat Application

This project consists of a Flask server powered by Google's Gemini AI model and mobile apps for Android and iOS.

## Project Structure

```
VertexGeminiApp/
├── app.py                 # Flask server
├── requirements.txt       # Python dependencies
├── Dockerfile            # For Cloud Run deployment
├── .gcloudignore         # Files to ignore during deployment
├── android/              # Android app
└── ios/                  # iOS app
```

## Setup and Testing

### 1. Local Server Testing

First, install the required dependencies:

```bash
pip install -r requirements.txt
```

Set up authentication for Google Cloud:

```bash
gcloud auth application-default login
```

Run the Flask server locally:

```bash
python app.py
```

The server will run on `http://localhost:8080`

Test the API endpoints:

```bash
# Health check
curl http://localhost:8080/health

# Send a chat message
curl -X POST http://localhost:8080/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello", "session_id": "test"}'
```

### 2. Android App

1. Open the `android/` folder in Android Studio
2. Update the base URL in `ChatRepository.kt`:
   - For emulator: Keep `http://10.0.2.2:8080/`
   - For device: Use your machine's IP address
3. Run the app on an emulator or device

### 3. iOS App

1. Open `ios/GeminiChat/` in Xcode
2. Update the base URL in `ChatService.swift`:
   - For simulator: Keep `http://localhost:8080`
   - For device: Use your machine's IP address
3. Run the app on a simulator or device

## Cloud Run Deployment

After testing locally, deploy to Cloud Run:

```bash
gcloud run deploy flask-chat-app --source . --region=asia-northeast3 --allow-unauthenticated
```

After deployment, update the mobile apps with the Cloud Run URL:
- Android: Update `baseUrl` in `ChatRepository.kt`
- iOS: Update `baseURL` in `ChatService.swift`

## Features

- Real-time chat with Gemini AI
- Message timestamps in KST (Korea Standard Time)
- Session management
- Error handling and connection status
- Clean, modern UI for both platforms

## Environment Variables

The server uses these environment variables:
- `PROJECT_ID`: Google Cloud project ID (default: sesac-dev-400904)
- `LOCATION`: Vertex AI location (default: us-central1)
- `PORT`: Server port (default: 8080)

## Notes

- The server stores chat sessions in memory (use a database for production)
- Mobile apps need network permissions configured
- iOS apps need to allow localhost connections for development