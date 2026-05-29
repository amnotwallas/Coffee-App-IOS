import Foundation
import Combine

class ProductDetailViewModel: ObservableObject {
    private let productService = ProductService.shared
    private let cartService = CartService.shared
    
    @Published var product: Product?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Estado para personalizaciones seleccionadas
    @Published var selectedOptions: [String: String] = [:]
    
    func loadProduct(id: String) {
        isLoading = true
        errorMessage = nil
        
        productService.getProductDetail(id: id) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let product):
                    self?.product = product
                    // Inicializar opciones por defecto si existen
                    self?.initializeDefaultOptions(for: product)
                case .failure(let error):
                    self?.errorMessage = error.message
                }
            }
        }
    }
    
    private func initializeDefaultOptions(for product: Product) {
        var options: [String: String] = [:]
        product.personalizaciones?.forEach { personalization in
            if let firstOption = personalization.opciones.first {
                options[personalization.tipo] = firstOption.nombre
            }
        }
        self.selectedOptions = options
    }
    
    func addToCart() {
        guard let product = product else { return }
        
        guard TokenManager.shared.getToken() != nil else {
            DispatchQueue.main.async {
                AppContext.shared.showLoginPrompt = true
            }
            return
        }
        
        cartService.addToCart(productId: product.id, quantity: 1, personalizaciones: selectedOptions) { result in
            if case .failure(let error) = result {
                print("Error al añadir al carrito: \(error.message)")
            }
        }
    }
}
