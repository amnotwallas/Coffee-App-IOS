import Foundation

struct UserProfile: Codable, Sendable {
    let id: String?
    let firebase_uid: String?
    let nombre: String?
    let email: String?
    let is_admin: Bool?
    let telefono: String?
    let foto: String?
    let direcciones: [Address]?
    let preferencias: UserPreferences?
}

struct Address: Codable, Sendable {
    let id: String?
    let calle: String
    let ciudad: String
    let codigoPostal: String
    let referencia: String?
    let esDefault: Bool
}

struct UserPreferences: Codable, Sendable {
    let notificacionesPush: Bool?
    let tipoLecheFavorita: String?
    let idioma: String?
}
