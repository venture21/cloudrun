package com.example.geminichat

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.launch
import java.util.UUID

class ChatViewModel : ViewModel() {
    private val repository = ChatRepository()
    private val sessionId = UUID.randomUUID().toString()
    
    private val _messages = MutableLiveData<List<ChatMessage>>(emptyList())
    val messages: LiveData<List<ChatMessage>> = _messages
    
    private val _isLoading = MutableLiveData(false)
    val isLoading: LiveData<Boolean> = _isLoading
    
    private val _connectionError = MutableLiveData<String?>()
    val connectionError: LiveData<String?> = _connectionError

    fun sendMessage(content: String) {
        viewModelScope.launch {
            _isLoading.value = true
            _connectionError.value = null
            
            // Add user message
            val userMessage = ChatMessage(
                content = content,
                isUser = true,
                timestamp = System.currentTimeMillis()
            )
            addMessage(userMessage)
            
            try {
                // Send to API and get response
                val response = repository.sendMessage(content, sessionId)
                
                // Add bot response
                val botMessage = ChatMessage(
                    content = response.response,
                    isUser = false,
                    timestamp = System.currentTimeMillis(),
                    formattedTime = response.timestamp
                )
                addMessage(botMessage)
                
            } catch (e: Exception) {
                _connectionError.value = e.message
                // Add error message
                val errorMessage = ChatMessage(
                    content = "Failed to get response. Please try again.",
                    isUser = false,
                    timestamp = System.currentTimeMillis()
                )
                addMessage(errorMessage)
            } finally {
                _isLoading.value = false
            }
        }
    }
    
    private fun addMessage(message: ChatMessage) {
        val currentMessages = _messages.value ?: emptyList()
        _messages.value = currentMessages + message
    }
    
    fun resetChat() {
        viewModelScope.launch {
            try {
                repository.resetChat(sessionId)
                _messages.value = emptyList()
            } catch (e: Exception) {
                _connectionError.value = e.message
            }
        }
    }
}