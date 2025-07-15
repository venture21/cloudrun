const socket = io();
let typingTimer;
let isTyping = false;

socket.on('connect', function() {
    console.log('Connected to server');
});

socket.on('previous_messages', function(messages) {
    messages.forEach(msg => {
        displayMessage(msg);
    });
    scrollToBottom();
});

socket.on('message', function(data) {
    displayMessage(data);
    scrollToBottom();
});

socket.on('user_typing', function(data) {
    const indicator = document.getElementById('typing-indicator');
    if (data.isTyping) {
        indicator.textContent = `${data.username}님이 입력 중...`;
    } else {
        indicator.textContent = '';
    }
});

function sendMessage() {
    const messageInput = document.getElementById('messageInput');
    const usernameInput = document.getElementById('username');
    
    const message = messageInput.value.trim();
    const username = usernameInput.value.trim() || 'Anonymous';
    
    if (message) {
        socket.emit('message', {
            username: username,
            message: message
        });
        
        messageInput.value = '';
        stopTyping();
    }
}

function displayMessage(data) {
    const messagesDiv = document.getElementById('messages');
    const messageDiv = document.createElement('div');
    messageDiv.className = 'message';
    
    messageDiv.innerHTML = `
        <div class="message-header">
            <span class="username">${data.username}</span>
            <span class="timestamp">${data.timestamp}</span>
        </div>
        <div class="message-content">${data.message}</div>
    `;
    
    messagesDiv.appendChild(messageDiv);
}

function scrollToBottom() {
    const messagesDiv = document.getElementById('messages');
    messagesDiv.scrollTop = messagesDiv.scrollHeight;
}

function startTyping() {
    if (!isTyping) {
        isTyping = true;
        const username = document.getElementById('username').value || 'Anonymous';
        socket.emit('user_typing', { username: username, isTyping: true });
    }
    
    clearTimeout(typingTimer);
    typingTimer = setTimeout(stopTyping, 1000);
}

function stopTyping() {
    if (isTyping) {
        isTyping = false;
        const username = document.getElementById('username').value || 'Anonymous';
        socket.emit('user_typing', { username: username, isTyping: false });
    }
}

document.getElementById('messageInput').addEventListener('keypress', function(e) {
    if (e.key === 'Enter') {
        sendMessage();
    } else {
        startTyping();
    }
});

document.getElementById('messageInput').addEventListener('input', function() {
    startTyping();
});