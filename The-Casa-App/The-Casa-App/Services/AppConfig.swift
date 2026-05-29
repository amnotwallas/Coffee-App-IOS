import Foundation

enum AppEnvironment {
    case local
    case production
    
    var host: String {
        switch self {
        case .local: return "http://localhost:8000"
        case .production: return "https://the-casa-coffee-api.vercel.app"
        }
    }
}

struct AppConfig {
    /// .local or .production
    static let environment: AppEnvironment = .production
    
    /// Versión actual de la API
    static let apiVersion = "/api/v1"
    
    /// URL base generada automáticamente. Evita errores de concatenación manual.
    static var baseURL: String {
        return environment.host + apiVersion
    }
    
    static let firebaseApiKey = ""
}
