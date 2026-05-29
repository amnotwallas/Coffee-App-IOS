import Foundation

struct CartItem: Codable, Identifiable {
    let cartItemId: String?
    let productId: String?
    let nombre: String?
    let imagen: String?
    let precio: Double?
    let cantidad: Int?
    let personalizaciones: [String: String]?
    let subtotal: Double?
    
    var id: String { cartItemId ?? UUID().uuidString }
    
    enum CodingKeys: String, CodingKey {
        case cartItemId, productId, nombre, imagen, precio, cantidad, personalizaciones, subtotal
    }
}

struct Cart: Codable {
    let items: [CartItem]?
    let total: Double?
    let itemsCount: Int?
    
    // Inicializador manual para atrapar errores específicos de campo
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Atrapamos errores por campo para que no se caiga todo el objeto
        self.items = try? container.decode([CartItem].self, forKey: .items)
        
        // El total a veces viene como Int o String en APIs inconsistentes
        if let totalDouble = try? container.decode(Double.self, forKey: .total) {
            self.total = totalDouble
        } else if let totalInt = try? container.decode(Int.self, forKey: .total) {
            self.total = Double(totalInt)
        } else {
            self.total = 0.0
        }
        
        self.itemsCount = try? container.decode(Int.self, forKey: .itemsCount)
        
        print("🛠 Decodificación Manual: items=\(items?.count ?? 0), total=\(total ?? 0)")
    }
    
    enum CodingKeys: String, CodingKey {
        case items, total, itemsCount
    }
}

struct CouponResponse: Codable {
    let discount: Double
    let newTotal: Double
    let couponApplied: String
}
