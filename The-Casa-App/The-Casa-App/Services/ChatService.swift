import Foundation

protocol ChatServiceDelegate: AnyObject {
    func chatServiceDidReceiveChunk(_ text: String)
    func chatServiceDidReceiveMetadata(conversationId: String, suggestions: [String]?)
    func chatServiceDidFinish()
    func chatServiceDidFail(error: Error)
}

class ChatService: NSObject, URLSessionDataDelegate {
    static let shared = ChatService()
    
    private var session: URLSession?
    weak var delegate: ChatServiceDelegate?
    
    private override init() {
        super.init()
        let config = URLSessionConfiguration.default
        // Importante: No queremos timeout corto para streams
        config.timeoutIntervalForRequest = 60
        self.session = URLSession(configuration: config, delegate: self, delegateQueue: .main)
    }
    
    func sendMessage(_ message: String, conversationId: String?) {
        guard let url = URL(string: "\(AppConfig.baseURL)/chat/message") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("text/event-stream", forHTTPHeaderField: "Accept")
        
        if let token = TokenManager.shared.getToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let body: [String: Any] = [
            "message": message,
            "conversationId": conversationId as Any
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = session?.dataTask(with: request)
        task?.resume()
    }
    
    // MARK: - URLSessionDataDelegate
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let string = String(data: data, encoding: .utf8) else { return }
        
        // El API envía líneas que empiezan con "data: "
        let lines = string.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            guard trimmedLine.starts(with: "data: ") else { continue }
            
            let content = String(trimmedLine.dropFirst(6)) // Eliminar "data: " exacto
            
            if content == "[DONE]" {
                delegate?.chatServiceDidFinish()
                continue
            }
            
            // Intentar decodificar como JSON para metadatos
            if let jsonData = content.data(using: .utf8),
               let response = try? JSONDecoder().decode(ChatMessageResponse.self, from: jsonData) {
                delegate?.chatServiceDidReceiveMetadata(conversationId: response.conversationId, suggestions: response.suggestions)
            } else {
                // Si no es JSON, es un fragmento de texto. 
                // No usamos trimmingCharacters aquí para no perder espacios intencionales
                delegate?.chatServiceDidReceiveChunk(content)
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            delegate?.chatServiceDidFail(error: error)
        } else {
            delegate?.chatServiceDidFinish()
        }
    }
}
