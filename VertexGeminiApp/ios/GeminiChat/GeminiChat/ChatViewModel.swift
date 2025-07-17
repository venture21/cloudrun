import Foundation
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var connectionError: String?
    
    private let chatService = ChatService()
    private let sessionId = UUID().uuidString
    private var cancellables = Set<AnyCancellable>()
    
    func sendMessage(_ content: String) {
        isLoading = true
        connectionError = nil
        
        // Add user message
        let userMessage = ChatMessage(
            content: content,
            isUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)
        
        // Send to API
        chatService.sendMessage(content, sessionId: sessionId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.connectionError = error.localizedDescription
                        // Add error message
                        let errorMessage = ChatMessage(
                            content: "Failed to get response. Please try again.",
                            isUser: false,
                            timestamp: Date()
                        )
                        self?.messages.append(errorMessage)
                    }
                },
                receiveValue: { [weak self] response in
                    let botMessage = ChatMessage(
                        content: response.response,
                        isUser: false,
                        timestamp: Date(),
                        formattedTime: response.timestamp
                    )
                    self?.messages.append(botMessage)
                }
            )
            .store(in: &cancellables)
    }
    
    func resetChat() {
        chatService.resetChat(sessionId: sessionId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.connectionError = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.messages.removeAll()
                }
            )
            .store(in: &cancellables)
    }
}