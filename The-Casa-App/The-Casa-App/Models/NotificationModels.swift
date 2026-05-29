import Foundation

enum NotificationType: String, Codable {
    case orderStatus = "ORDER_STATUS"
    case promo = "PROMO"
    case info = "INFO"
}

struct CoffeeNotification: Codable, Identifiable {
    let id: String
    let tipo: String // Mantenemos como String para mayor flexibilidad al decodificar
    let titulo: String
    let mensaje: String
    let leida: Bool
    let fecha: String
    let data: [String: String]?
    
    // Helper para obtener el tipo como Enum
    var notificationType: NotificationType {
        NotificationType(rawValue: tipo) ?? .info
    }
}
