import Foundation

struct APIErrorResponse: Codable {
    let status: String
    let code: String
    let message: String
    let timestamp: String
}

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case apiError(APIErrorResponse)
    case decodingError(Error)
    case unauthorized
    
    var message: String {
        switch self {
        case .invalidURL: return "URL inválida"
        case .networkError: return "Error de conexión"
        case .invalidResponse: return "Respuesta del servidor inválida"
        case .apiError(let response): return response.message
        case .decodingError: return "Error al procesar los datos"
        case .unauthorized: return "Sesión expirada o no autorizada"
        }
    }
}
