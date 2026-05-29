import Foundation

class AIService {
    static let shared = AIService()
    private let client = APIClient.shared
    
    private init() {}
    
    func fetchWelcome(completion: @escaping (Result<WelcomeResponse, APIError>) -> Void) {
        client.execute(CoffeeEndpoint.welcome, completion: completion)
    }
}
