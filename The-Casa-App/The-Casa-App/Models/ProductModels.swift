import Foundation

struct Categoria: Codable {
    let id: Int
    let nombre: String
}

struct ValoresNutricionales: Codable {
    let calorias: Int?
    let proteinas: Double?
    let grasas: Double?
    let carbohidratos: Double?
}

struct OpcionPersonalizacion: Codable {
    let nombre: String
    let extra_precio: Double
    let valor: String?
}

struct Personalizacion: Codable {
    let tipo: String
    let opciones: [OpcionPersonalizacion]
}

struct Product: Codable, Identifiable {
    let id: String
    let nombre: String
    let descripcion: String?
    let precio: Double
    let intensidad: Int?
    let imagenes: [String]?
    let icon: String?
    let categoria: Categoria?
    let ingredientes: [String]?
    let valores_nutricionales: ValoresNutricionales?
    let personalizaciones: [Personalizacion]?
    let reviews_count: Int?
    let rating_avg: Double?
    let disponible: Bool?
    
    // Helper para obtener la primera imagen o un placeholder
    var principalImagenUrl: String? {
        return imagenes?.first
    }
}

struct PaginatedProducts: Codable {
    let data: [Product]
    let total: Int
    let page: Int
}

struct SearchResponse: Codable {
    let results: [Product]
    let count: Int
}
