import Foundation
import Combine

struct ChatRequest: Codable {
    let message: String
    let session_id: String
}

struct ChatResponse: Codable {
    let response: String
    let timestamp: String
    let session_id: String
}

struct ResetRequest: Codable {
    let session_id: String
}

class ChatService {
    private let baseURL: String
    private let session: URLSession
    
    init() {
        // For local testing, use localhost or your machine's IP
        // For production, replace with your Cloud Run URL
        #if targetEnvironment(simulator)
        self.baseURL = "http://localhost:8080"
        #else
        self.baseURL = "http://localhost:8080" // Replace with your machine's IP for device testing
        #endif
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }
    
    func sendMessage(_ message: String, sessionId: String) -> AnyPublisher<ChatResponse, Error> {
        guard let url = URL(string: "\(baseURL)/chat") else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let chatRequest = ChatRequest(message: message, session_id: sessionId)
        
        do {
            request.httpBody = try JSONEncoder().encode(chatRequest)
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: ChatResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func resetChat(sessionId: String) -> AnyPublisher<Void, Error> {
        guard let url = URL(string: "\(baseURL)/chat/reset") else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let resetRequest = ResetRequest(session_id: sessionId)
        
        do {
            request.httpBody = try JSONEncoder().encode(resetRequest)
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}