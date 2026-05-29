import Foundation
import SwiftUI
import Combine

class CheckoutViewModel: ObservableObject {
    @Published var shippingMethods: [ShippingMethod] = []
    @Published var selectedMethod: ShippingMethod?
    @Published var selectedAddress: Address?
    @Published var notes: String = ""
    @Published var propina: Double = 0.0
    @Published var isLoading: Bool = false
    @Published var orderSuccess: CheckoutResponse?
    @Published var errorMessage: String?
    
    private let orderService = OrderService.shared
    
    init() {
        loadShippingMethods()
    }
    
    func loadShippingMethods() {
        isLoading = true
        orderService.fetchShippingMethods { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                if case .success(let methods) = result {
                    self?.shippingMethods = methods
                    // Default a recoger (id 1) si existe
                    self?.selectedMethod = methods.first(where: { $0.id == 1 }) ?? methods.first
                }
            }
        }
    }
    
    var subtotal: Double {
        AppContext.shared.activeCart?.total ?? 0.0
    }
    
    var shippingCost: Double {
        selectedMethod?.costo ?? 0.0
    }
    
    var total: Double {
        subtotal + shippingCost + propina
    }
    
    var isPhoneRequired: Bool {
        AppContext.shared.currentUser?.telefono == nil
    }
    
    var canConfirm: Bool {
        // Requisito de perfil (Capa 3 del protocolo de identidad)
        if isPhoneRequired { return false }
        
        // Si es envío (id 2), requiere dirección
        if selectedMethod?.id == 2 {
            return selectedAddress != nil
        }
        return selectedMethod != nil
    }
    
    func confirmOrder() {
        guard let method = selectedMethod else { return }
        
        // Ajustar tipo de pago según el método para evitar 422
        let paymentType = (method.id == 2) ? "tarjeta" : "efectivo"
        
        isLoading = true
        orderService.checkout(
            shippingMethodId: method.id,
            addressId: selectedAddress?.id,
            tipoPago: paymentType,
            notes: notes.isEmpty ? nil : notes,
            propina: propina
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    self?.orderSuccess = response
                    CartService.shared.fetchCart() // Limpiar/Actualizar carrito tras éxito
                case .failure:
                    self?.errorMessage = "No se pudo procesar tu pedido"
                }
            }
        }
    }
}
