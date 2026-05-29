import Foundation

class APIClient {
    static let shared = APIClient()
    private let baseURL = AppConfig.baseURL
    
    // Control de peticiones en curso para evitar duplicados
    private var activeTasks: [String: [(Result<Data, APIError>) -> Void]] = [:]
    private let queue = DispatchQueue(label: "com.thecasaapp.apiclient")
    
    private init() {}
    
    func execute<T: Codable>(_ endpoint: APIEndpoint, completion: @escaping (Result<T, APIError>) -> Void) {
        let cacheKey = endpoint.path + (endpoint.queryItems?.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&") ?? "")
        
        // 1. Cache Check
        if let ttl = endpoint.cacheTTL, let cachedData = APICache.shared.get(for: cacheKey) {
            decode(cachedData, completion: completion)
            return
        }
        
        // 2. Deduplicación de peticiones
        queue.async {
            if self.activeTasks[cacheKey] != nil {
                self.activeTasks[cacheKey]?.append { result in
                    switch result {
                    case .success(let data): self.decode(data, completion: completion)
                    case .failure(let error): completion(.failure(error))
                    }
                }
                return
            }
            
            self.activeTasks[cacheKey] = [{ result in
                switch result {
                case .success(let data): self.decode(data, completion: completion)
                case .failure(let error): completion(.failure(error))
                }
            }]
            
            self.performRequest(endpoint, cacheKey: cacheKey)
        }
    }
    
    private func performRequest(_ endpoint: APIEndpoint, cacheKey: String) {
        guard var request = endpoint.request(baseURL: baseURL) else {
            notifySubscribers(cacheKey, result: .failure(.invalidURL))
            return
        }
        
        if let token = TokenManager.shared.getToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Añadir ID de Idempotencia para Checkout (Requerido por el API)
        if endpoint.path.contains("/checkout") {
            let idempotencyKey = UUID().uuidString
            request.addValue(idempotencyKey, forHTTPHeaderField: "X-Idempotency-Key")
            print("🔑 Idempotency Key generada: \(idempotencyKey)")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.notifySubscribers(cacheKey, result: .failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                self.notifySubscribers(cacheKey, result: .failure(.invalidResponse))
                return
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                if let _ = endpoint.cacheTTL {
                    APICache.shared.set(data, for: cacheKey, ttl: endpoint.cacheTTL)
                }
                
                // FORCE DEBUG: Log raw data for ANY request containing 'cart', 'user' or 'address'
                let lowerPath = endpoint.path.lowercased()
                if lowerPath.contains("cart") || lowerPath.contains("user") || lowerPath.contains("address") {
                    if let rawString = String(data: data, encoding: .utf8) {
                        print("📡 [API DEBUG] RAW Response (\(endpoint.path)): \(rawString)")
                    }
                }
                
                self.notifySubscribers(cacheKey, result: .success(data))
            } else if httpResponse.statusCode == 401 {
                self.notifySubscribers(cacheKey, result: .failure(.unauthorized))
            } else {
                // FORCE DEBUG: Log raw error data for Checkout
                if endpoint.path.contains("/checkout") {
                    if let rawErrorString = String(data: data, encoding: .utf8) {
                        print("📡 [CHECKOUT ERROR] RAW Response: \(rawErrorString)")
                    }
                }
                self.notifySubscribers(cacheKey, result: .failure(.invalidResponse))
            }
        }.resume()
    }
    
    private func notifySubscribers(_ key: String, result: Result<Data, APIError>) {
        queue.async {
            let subscribers = self.activeTasks[key] ?? []
            self.activeTasks.removeValue(forKey: key)
            DispatchQueue.main.async {
                subscribers.forEach { $0(result) }
            }
        }
    }
    
    private func decode<T: Codable>(_ data: Data, completion: @escaping (Result<T, APIError>) -> Void) {
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            DispatchQueue.main.async { completion(.success(decoded)) }
        } catch {
            print("❌ Decoding Error: \(error)")
            DispatchQueue.main.async { completion(.failure(.decodingError(error))) }
        }
    }
}
