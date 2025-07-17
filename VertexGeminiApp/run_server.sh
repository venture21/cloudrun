#!/bin/bash
# Kill any existing Flask processes
pkill -f "python app.py" 2>/dev/null || true
sleep 1

# Run Flask server
echo "Starting Flask server..."
python app.py