import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    var formattedTime: String?
    
    var displayTime: String {
        if let formattedTime = formattedTime {
            return formattedTime
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter.string(from: timestamp)
    }
}