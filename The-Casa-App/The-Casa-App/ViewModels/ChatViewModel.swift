import Foundation
import Combine

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    var text: String
    let isUser: Bool
    let timestamp = Date()
}

class ChatViewModel: ObservableObject, ChatServiceDelegate {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading: Bool = false
    @Published var conversationId: String?
    
    private let chatService = ChatService.shared
    
    init() {
        chatService.delegate = self
        // Mensaje de bienvenida estático
        messages.append(ChatMessage(text: "¡Hola! Soy tu Barista AI. ¿En qué puedo ayudarte hoy?", isUser: false))
    }
    
    func sendMessage(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMsg = ChatMessage(text: text, isUser: true)
        messages.append(userMsg)
        
        isLoading = true
        
        // Iniciamos un mensaje vacío para la respuesta de la IA
        let aiMsg = ChatMessage(text: "", isUser: false)
        messages.append(aiMsg)
        
        chatService.sendMessage(text, conversationId: conversationId)
    }
    
    func clearChat() {
        messages.removeAll()
        messages.append(ChatMessage(text: "¡Hola! Soy tu Barista AI. ¿En qué puedo ayudarte hoy?", isUser: false))
        conversationId = nil
    }
    
    // MARK: - ChatServiceDelegate
    
    func chatServiceDidReceiveMetadata(conversationId: String, suggestions: [String]?) {
        DispatchQueue.main.async {
            self.conversationId = conversationId
            // Podríamos guardar sugerencias aquí si quisiéramos
        }
    }
    
    func chatServiceDidReceiveChunk(_ text: String) {
        DispatchQueue.main.async {
            if let lastIdx = self.messages.indices.last, !self.messages[lastIdx].isUser {
                // Concatenamos el texto tal cual llega para preservar espacios y puntuación
                self.messages[lastIdx].text += text
                // Forzamos el aviso de cambio para que la vista haga scroll
                self.objectWillChange.send()
            }
        }
    }
    
    func chatServiceDidFinish() {
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    func chatServiceDidFail(error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false
            if let lastIdx = self.messages.indices.last, !self.messages[lastIdx].isUser, self.messages[lastIdx].text.isEmpty {
                self.messages[lastIdx].text = "Lo siento, tuve un problema de conexión. ¿Podrías intentar de nuevo?"
            }
            print("Chat error: \(error.localizedDescription)")
        }
    }
}
