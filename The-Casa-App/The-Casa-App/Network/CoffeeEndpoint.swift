import Foundation

enum CoffeeEndpoint: APIEndpoint {
    // AI & Support
    case welcome
    case listProducts(category: Int?, page: Int, limit: Int)
    case productDetail(id: String)
    case searchProducts(query: String)
    case chatMessage(message: String, conversationId: String?)
    case chatHistory
    
    // Cart
    case getCart
    case addToCart(productId: String, quantity: Int, personalizaciones: [String: String]?)
    case updateCartItem(id: String, cantidad: Int)
    case removeCartItem(id: String)
    case clearCart
    case applyCoupon(code: String)
    
    // User
    case getProfile
    case updateProfile(nombre: String?, telefono: String?)
    case getAddresses
    case addAddress(calle: String, ciudad: String, codigoPostal: String, referencia: String?, esDefault: Bool)
    case deleteAddress(id: String)
    case getFavorites
    case addFavorite(productId: String)
    case removeFavorite(productId: String)
    
    // Orders
    case getShippingMethods
    case checkout(shippingMethodId: Int, addressId: String?, tipoPago: String, notas: String?, propina: Double)
    case getOrders
    case getOrderDetail(id: String)
    case getActiveOrders
    case getOrderTracking(id: String)
    case cancelOrder(id: String)
    
    // Store & Promo
    case getStoreInfo
    case getStoreHours
    case getPromotions
    case validateCoupon(code: String)
    
    // Notifications
    case getNotifications
    case markNotificationRead(id: String)
    case markAllNotificationsRead
    case registerToken(token: String, platform: String)
    
    var path: String {
        switch self {
        case .welcome: return "/chat/welcome"
        case .listProducts: return "/products"
        case .productDetail(let id): return "/products/\(id)"
        case .searchProducts: return "/products/search"
        case .chatMessage: return "/chat/message"
        case .chatHistory: return "/chat/history"
        case .getCart: return "/cart/"
        case .addToCart: return "/cart/add"
        case .updateCartItem(let id, _): return "/cart/item/\(id)"
        case .removeCartItem(let id): return "/cart/item/\(id)"
        case .clearCart: return "/cart/clear"
        case .applyCoupon: return "/cart/apply-coupon"
        case .getProfile: return "/user/profile"
        case .updateProfile: return "/user/profile"
        case .getAddresses: return "/user/addresses"
        case .addAddress: return "/user/addresses"
        case .deleteAddress(let id): return "/user/addresses/\(id)"
        case .getFavorites: return "/user/favorites"
        case .addFavorite(let id): return "/user/favorites/\(id)"
        case .removeFavorite(let id): return "/user/favorites/\(id)"
        case .getShippingMethods: return "/orders/shipping-methods/"
        case .checkout: return "/orders/checkout"
        case .getOrders: return "/orders/"
        case .getOrderDetail(let id): return "/orders/\(id)"
        case .getActiveOrders: return "/orders/active"
        case .getOrderTracking(let id): return "/orders/\(id)/tracking"
        case .cancelOrder(let id): return "/orders/\(id)/cancel"
        case .getStoreInfo: return "/store/info"
        case .getStoreHours: return "/store/hours"
        case .getPromotions: return "/promotions"
        case .validateCoupon: return "/coupons/validate"
        case .getNotifications: return "/notifications"
        case .markNotificationRead(let id): return "/notifications/\(id)/read"
        case .markAllNotificationsRead: return "/notifications/read-all"
        case .registerToken: return "/notifications/token"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .welcome, .listProducts, .productDetail, .searchProducts, .chatHistory, .getCart, .getProfile, .getAddresses, .getFavorites, .getOrders, .getOrderDetail, .getActiveOrders, .getOrderTracking, .getStoreInfo, .getStoreHours, .getPromotions, .getNotifications, .getShippingMethods:
            return .get
        case .chatMessage, .addToCart, .addAddress, .getFavorites, .addFavorite, .checkout, .applyCoupon, .validateCoupon, .registerToken:
            return .post
        case .updateCartItem, .updateProfile, .markNotificationRead, .markAllNotificationsRead, .cancelOrder:
            return .patch
        case .removeCartItem, .clearCart, .deleteAddress, .removeFavorite:
            return .delete
        }
    }
    
    var cacheTTL: TimeInterval? {
        switch self {
        case .listProducts, .productDetail, .searchProducts:
            return 300
        case .welcome:
            return 600
        case .getStoreInfo, .getStoreHours:
            return 3600
        default:
            return nil
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .listProducts(let category, let page, let limit):
            var items = [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "limit", value: "\(limit)")
            ]
            if let category = category {
                items.append(URLQueryItem(name: "category", value: "\(category)"))
            }
            return items
        case .searchProducts(let query):
            return [URLQueryItem(name: "q", value: query)]
        case .applyCoupon(let code):
            return [URLQueryItem(name: "code", value: code)]
        case .validateCoupon(let code):
            return [URLQueryItem(name: "code", value: code)]
        case .registerToken(let token, let platform):
            return [
                URLQueryItem(name: "deviceToken", value: token),
                URLQueryItem(name: "platform", value: platform)
            ]
        default:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .chatMessage(let message, let conversationId):
            let dict: [String: Any] = [
                "message": message,
                "conversationId": conversationId as Any
            ]
            return try? JSONSerialization.data(withJSONObject: dict)
            
        case .addToCart(let productId, let quantity, let personalizaciones):
            let dict: [String: Any] = [
                "productId": productId,
                "cantidad": quantity,
                "personalizaciones": personalizaciones as Any
            ]
            return try? JSONSerialization.data(withJSONObject: dict)
            
        case .updateCartItem(_, let cantidad):
            let dict: [String: Any] = ["cantidad": cantidad]
            return try? JSONSerialization.data(withJSONObject: dict)
            
        case .updateProfile(let nombre, let telefono):
            var dict: [String: Any] = [:]
            if let nombre = nombre { dict["nombre"] = nombre }
            if let telefono = telefono { dict["telefono"] = telefono }
            return try? JSONSerialization.data(withJSONObject: dict)
            
        case .addAddress(let calle, let ciudad, let cp, let ref, let isDefault):
            let dict: [String: Any] = [
                "calle": calle,
                "ciudad": ciudad,
                "codigoPostal": cp,
                "referencia": ref as Any,
                "esDefault": isDefault
            ]
            return try? JSONSerialization.data(withJSONObject: dict)
            
        case .checkout(let shippingId, let addrId, let pago, let notas, let propina):
            var dict: [String: Any] = [
                "shippingMethodId": shippingId,
                "tipoPago": pago,
                "propina": propina
            ]
            
            // Solo añadir si no son nil o vacíos para evitar validaciones fallidas
            if let addrId = addrId, !addrId.isEmpty {
                dict["addressId"] = addrId
            }
            
            if let notas = notas, !notas.isEmpty {
                dict["notas"] = notas
            } else {
                dict["notas"] = NSNull() // O simplemente no enviarlo si el API lo permite
            }
            
            return try? JSONSerialization.data(withJSONObject: dict)
            
        default:
            return nil
        }
    }
}
