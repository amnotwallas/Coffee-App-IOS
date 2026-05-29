import Foundation
import SwiftUI
import Combine

class CartViewModel: ObservableObject {
    @Published var cart: Cart?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let cartService = CartService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        print("🛠 CartViewModel Inicializado")
    }
    
    func loadCart() {
        print("📡 Iniciando carga del carrito...")
        isLoading = true
        errorMessage = nil
        
        cartService.fetchCart { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let cart):
                    print("✅ Carrito recibido exitosamente: \(cart.items?.count ?? 0) productos")
                    self?.cart = cart
                case .failure(let error):
                    print("❌ Error en petición de carrito: \(error.message)")
                    self?.errorMessage = "No se pudo cargar el carrito: \(error.message)"
                }
            }
        }
    }
    
    func updateQuantity(for item: CartItem, delta: Int) {
        guard let cartItemId = item.cartItemId else { return }
        let currentQuantity = item.cantidad ?? 0
        let newQuantity = currentQuantity + delta
        
        if newQuantity <= 0 {
            remove(item: item)
        } else {
            isLoading = true
            cartService.updateItemQuantity(cartItemId: cartItemId, quantity: newQuantity) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if case .success(let updatedCart) = result {
                        self?.cart = updatedCart
                    }
                }
            }
        }
    }
    
    func remove(item: CartItem) {
        guard let cartItemId = item.cartItemId else { return }
        isLoading = true
        cartService.removeItem(cartItemId: cartItemId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                if case .success(let updatedCart) = result {
                    self?.cart = updatedCart
                }
            }
        }
    }
}
