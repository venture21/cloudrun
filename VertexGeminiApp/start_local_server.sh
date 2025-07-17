#!/bin/bash

# Start Flask server for local development with Android emulator

echo "Starting Flask server for local development..."
echo "Server will be accessible at:"
echo "  - http://localhost:8080 (from host machine)"
echo "  - http://10.0.2.2:8080 (from Android emulator)"

# Set environment variables
export FLASK_APP=app.py
export FLASK_ENV=development
export FLASK_DEBUG=1

# Start the Flask server
python app.py