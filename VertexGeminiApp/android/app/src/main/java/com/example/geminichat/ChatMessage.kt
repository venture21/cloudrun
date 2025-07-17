package com.example.geminichat

import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

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