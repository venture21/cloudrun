package com.example.geminichat

import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.Body
import retrofit2.http.POST
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import java.util.concurrent.TimeUnit

data class ChatRequest(
    val message: String,
    val session_id: String
)

data class ChatResponse(
    val response: String,
    val timestamp: String,
    val session_id: String
)

data class ResetRequest(
    val session_id: String
)

interface ChatApiService {
    @POST("/chat")
    suspend fun sendMessage(@Body request: ChatRequest): ChatResponse
    
    @POST("/chat/reset")
    suspend fun resetChat(@Body request: ResetRequest)
}

class ChatRepository {
    private val apiService: ChatApiService
    
    init {
        val loggingInterceptor = HttpLoggingInterceptor().apply {
            level = HttpLoggingInterceptor.Level.BODY
        }
        
        val client = OkHttpClient.Builder()
            .addInterceptor(loggingInterceptor)
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .writeTimeout(30, TimeUnit.SECONDS)
            .build()
        
        val retrofit = Retrofit.Builder()
            // For local testing: "http://10.0.2.2:8080/"
            // For Cloud Run production: Replace with your actual Cloud Run URL
            .baseUrl(BuildConfig.API_BASE_URL)
            .client(client)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
        
        apiService = retrofit.create(ChatApiService::class.java)
    }
    
    suspend fun sendMessage(message: String, sessionId: String): ChatResponse {
        return apiService.sendMessage(ChatRequest(message, sessionId))
    }
    
    suspend fun resetChat(sessionId: String) {
        apiService.resetChat(ResetRequest(sessionId))
    }
}