package com.example.geminichat

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView

class ChatAdapter : ListAdapter<ChatMessage, ChatAdapter.ChatViewHolder>(ChatDiffCallback()) {
    
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ChatViewHolder {
        val layoutId = if (viewType == VIEW_TYPE_USER) {
            R.layout.item_message_user
        } else {
            R.layout.item_message_bot
        }
        val view = LayoutInflater.from(parent.context).inflate(layoutId, parent, false)
        return ChatViewHolder(view)
    }
    
    override fun onBindViewHolder(holder: ChatViewHolder, position: Int) {
        holder.bind(getItem(position))
    }
    
    override fun getItemViewType(position: Int): Int {
        return if (getItem(position).isUser) VIEW_TYPE_USER else VIEW_TYPE_BOT
    }
    
    class ChatViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val messageText: TextView = itemView.findViewById(R.id.messageText)
        private val timeText: TextView = itemView.findViewById(R.id.timeText)
        
        fun bind(message: ChatMessage) {
            messageText.text = message.content
            timeText.text = message.getDisplayTime()
        }
    }
    
    class ChatDiffCallback : DiffUtil.ItemCallback<ChatMessage>() {
        override fun areItemsTheSame(oldItem: ChatMessage, newItem: ChatMessage): Boolean {
            return oldItem.timestamp == newItem.timestamp && oldItem.isUser == newItem.isUser
        }
        
        override fun areContentsTheSame(oldItem: ChatMessage, newItem: ChatMessage): Boolean {
            return oldItem == newItem
        }
    }
    
    companion object {
        private const val VIEW_TYPE_USER = 0
        private const val VIEW_TYPE_BOT = 1
    }
}