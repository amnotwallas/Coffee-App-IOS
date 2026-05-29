import Foundation

struct StoreInfo: Codable, Sendable {
    let id: Int?
    let nombre: String
    let direccion: String
    let email: String?
    let telefono: String?
    let estaAbierto: Bool
    let tiempo_espera_actual: Int?
    let volumen_pedidos: String?
}

struct StoreHour: Codable, Sendable {
    let dia: String
    let apertura: String
    let cierre: String
    let abierto: Bool
}

struct StoreHoursResponse: Codable, Sendable {
    let horarios: [StoreHour]
    let estaAbierto: Bool
    let tiempo_espera_actual: Int?
    let volumen_pedidos: String?
}
