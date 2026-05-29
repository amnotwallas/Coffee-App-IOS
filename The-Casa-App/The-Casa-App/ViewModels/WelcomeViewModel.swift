import Foundation
import Combine

class WelcomeViewModel: ObservableObject {
    private let aiService = AIService.shared
    private let cartService = CartService.shared
    
    @Published var welcomeMessage: String = ""
    @Published var recommendations: [Product] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var fullMessage: String = ""
    private var typingTask: Task<Void, Never>?
    
    func loadWelcomeData() {
        isLoading = true
        errorMessage = nil
        
        aiService.fetchWelcome { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    self?.startTypewriterEffect(with: response.message)
                    self?.recommendations = response.recommendations
                case .failure(let error):
                    self?.errorMessage = error.message
                }
            }
        }
    }
    
    private func startTypewriterEffect(with message: String) {
        typingTask?.cancel()
        welcomeMessage = ""
        fullMessage = message
        
        typingTask = Task {
            for char in message {
                try? await Task.sleep(nanoseconds: 30_000_000) // 0.03 segundos por letra
                if Task.isCancelled { break }
                
                await MainActor.run {
                    self.welcomeMessage.append(char)
                }
            }
        }
    }
    
    private func preloadImages(for products: [Product]) {
        for product in products {
            guard let urlString = product.principalImagenUrl, let url = URL(string: urlString) else { continue }
            URLSession.shared.dataTask(with: url).resume()
        }
    }
}
