# Android App Connection Troubleshooting Guide

## Quick Fix Steps

1. **Start the Flask server properly:**
   ```bash
   ./start_local_server.sh
   ```
   Or manually:
   ```bash
   python app.py
   ```

2. **Verify the server is running:**
   - Check if you see: `Running on all addresses (0.0.0.0)`
   - The server should be listening on port 8080

3. **Test the connection:**
   ```bash
   # From your host machine
   curl http://localhost:8080/health
   ```

## Common Issues and Solutions

### Connection Refused Error
- **Issue**: `failed to connect to /10.0.2.2(port 8080)`
- **Solution**: The Flask server is not running or not accessible

### Android Emulator Networking
- Android emulator uses `10.0.2.2` to connect to the host machine's `localhost`
- The app is already configured correctly to use this address

### Checklist
- [ ] Flask server is running (`python app.py`)
- [ ] Server shows "Running on all addresses (0.0.0.0)"
- [ ] Port 8080 is not blocked by firewall
- [ ] No other service is using port 8080
- [ ] Android app has INTERNET permission (already configured)
- [ ] Network security config allows cleartext traffic to 10.0.2.2 (already configured)

### Testing the Connection
1. Start the Flask server
2. Open another terminal and run:
   ```bash
   curl http://localhost:8080/health
   ```
   You should see: `{"status":"healthy"}`

3. In Android Studio, run the app on an emulator
4. The app should now connect successfully

### If Still Not Working
1. Check if another process is using port 8080:
   ```bash
   lsof -i :8080  # On Linux/Mac
   netstat -ano | findstr :8080  # On Windows
   ```

2. Try a different port by modifying:
   - In `app.py`: Change `port=8080` to another port
   - In `ChatRepository.kt`: Update the baseUrl accordingly

3. For physical devices (not emulator):
   - Use your computer's IP address instead of `10.0.2.2`
   - Make sure both devices are on the same network