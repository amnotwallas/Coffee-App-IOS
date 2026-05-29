import Foundation

class CartService {
    static let shared = CartService()
    private let client = APIClient.shared
    private let context = AppContext.shared
    
    private init() {}
    
    func fetchCart(completion: ((Result<Cart, APIError>) -> Void)? = nil) {
        print("🛒 CartService: Solicitando carrito al servidor...")
        client.execute(CoffeeEndpoint.getCart) { [weak self] (result: Result<Cart, APIError>) in
            switch result {
            case .success(let cart):
                print("🛒 CartService SUCCESS: \(cart.items?.count ?? 0) items")
                DispatchQueue.main.async {
                    self?.context.activeCart = cart
                }
            case .failure(let error):
                print("🛒 CartService FAILURE: \(error.message)")
            }
            completion?(result)
        }
    }
    
    func addToCart(productId: String, quantity: Int, personalizaciones: [String: String]?, completion: ((Result<Cart, APIError>) -> Void)? = nil) {
        client.execute(CoffeeEndpoint.addToCart(productId: productId, quantity: quantity, personalizaciones: personalizaciones)) { [weak self] (result: Result<Cart, APIError>) in
            if case .success(let cart) = result {
                DispatchQueue.main.async {
                    self?.context.activeCart = cart
                }
            }
            completion?(result)
        }
    }
    
    func updateItemQuantity(cartItemId: String, quantity: Int, completion: ((Result<Cart, APIError>) -> Void)? = nil) {
        client.execute(CoffeeEndpoint.updateCartItem(id: cartItemId, cantidad: quantity)) { [weak self] (result: Result<Cart, APIError>) in
            if case .success(let cart) = result {
                DispatchQueue.main.async {
                    self?.context.activeCart = cart
                }
            }
            completion?(result)
        }
    }
    
    func removeItem(cartItemId: String, completion: ((Result<Cart, APIError>) -> Void)? = nil) {
        client.execute(CoffeeEndpoint.removeCartItem(id: cartItemId)) { [weak self] (result: Result<Cart, APIError>) in
            if case .success(let cart) = result {
                DispatchQueue.main.async {
                    self?.context.activeCart = cart
                }
            }
            completion?(result)
        }
    }
    
    func clearCart(completion: ((Result<MessageResponse, APIError>) -> Void)? = nil) {
        client.execute(CoffeeEndpoint.clearCart) { [weak self] (result: Result<MessageResponse, APIError>) in
            if case .success = result {
                DispatchQueue.main.async {
                    self?.context.activeCart = nil
                }
            }
            completion?(result)
        }
    }
}
