import Foundation

class APICache {
    static let shared = APICache()
    private init() {}
    
    // Almacenamiento en memoria: [Path: (Data, ExpirationDate)]
    private var memoryCache: [String: (data: Data, expiration: Date)] = [:]
    
    // Tiempo de vida por defecto: 10 minutos
    private let defaultTTL: TimeInterval = 600
    
    func set(_ data: Data, for path: String, ttl: TimeInterval? = nil) {
        let expiration = Date().addingTimeInterval(ttl ?? defaultTTL)
        memoryCache[path] = (data, expiration)
    }
    
    func get(for path: String) -> Data? {
        guard let cached = memoryCache[path] else { return nil }
        
        // Verificar si ha expirado
        if Date() > cached.expiration {
            memoryCache.removeValue(forKey: path)
            return nil
        }
        
        return cached.data
    }
    
    func clear() {
        memoryCache.removeAll()
    }
}
