package com.example.geminichat

import android.os.Bundle
import android.view.View
import android.widget.EditText
import android.widget.ImageButton
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import kotlinx.coroutines.launch

class MainActivity : AppCompatActivity() {
    private lateinit var viewModel: ChatViewModel
    private lateinit var adapter: ChatAdapter
    private lateinit var recyclerView: RecyclerView
    private lateinit var messageInput: EditText
    private lateinit var sendButton: ImageButton
    private lateinit var connectionStatus: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        viewModel = ViewModelProvider(this)[ChatViewModel::class.java]
        
        setupViews()
        observeViewModel()
    }

    private fun setupViews() {
        recyclerView = findViewById(R.id.chatRecyclerView)
        messageInput = findViewById(R.id.messageInput)
        sendButton = findViewById(R.id.sendButton)
        connectionStatus = findViewById(R.id.connectionStatus)

        adapter = ChatAdapter()
        recyclerView.layoutManager = LinearLayoutManager(this)
        recyclerView.adapter = adapter

        sendButton.setOnClickListener {
            val message = messageInput.text.toString().trim()
            if (message.isNotEmpty()) {
                sendMessage(message)
            }
        }
    }

    private fun sendMessage(message: String) {
        messageInput.text.clear()
        viewModel.sendMessage(message)
    }

    private fun observeViewModel() {
        viewModel.messages.observe(this) { messages ->
            adapter.submitList(messages)
            recyclerView.scrollToPosition(messages.size - 1)
        }

        viewModel.isLoading.observe(this) { isLoading ->
            sendButton.isEnabled = !isLoading
        }

        viewModel.connectionError.observe(this) { error ->
            if (error != null) {
                connectionStatus.visibility = View.VISIBLE
                connectionStatus.text = "Connection error: $error"
            } else {
                connectionStatus.visibility = View.GONE
            }
        }
    }
}