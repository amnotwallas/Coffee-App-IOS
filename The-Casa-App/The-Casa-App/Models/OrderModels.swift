import Foundation

struct OrderTracking: Codable, Sendable {
    let preparando: Bool
    let listo: Bool
    let enCamino: Bool
    let entregado: Bool
}

enum OrderStatus: String, Codable {
    case pending, preparing, ready, shipped, delivered, cancelled
}

struct ShippingMethod: Codable, Identifiable, Sendable {
    let id: Int
    let nombre: String
    let costo: Double
}

struct Order: Codable, Identifiable, Sendable {
    let id: String
    let fecha: String
    let total: Double
    let status: String
    let items: [CartItem]?
    let tracking: OrderTracking?
    let tipoPedido: String?
    
    var orderStatus: OrderStatus {
        OrderStatus(rawValue: status) ?? .pending
    }
    
    enum CodingKeys: String, CodingKey {
        case id, fecha, total, status, items, tracking, tipoPedido
    }
}

struct CheckoutResponse: Codable, Sendable {
    let orderId: String
    let total: Double?
    let estimatedTime: String?
    let status: String?
    let createdAt: String?
}
