import requests
import json

# Test server endpoints
base_url = "http://localhost:8080"

# Test health check
try:
    response = requests.get(f"{base_url}/health")
    print(f"Health check: {response.status_code} - {response.json()}")
except Exception as e:
    print(f"Health check error: {e}")

# Test chat endpoint
try:
    data = {
        "message": "안녕하세요",
        "session_id": "test123"
    }
    response = requests.post(f"{base_url}/chat", json=data)
    print(f"\nChat response: {response.status_code}")
    if response.status_code == 200:
        result = response.json()
        print(f"AI response: {result['response']}")
        print(f"Timestamp: {result['timestamp']}")
    else:
        print(f"Error response: {response.text}")
except Exception as e:
    print(f"Chat error: {e}")