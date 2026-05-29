import Foundation
import Combine

class FavoritesViewModel: ObservableObject {
    @Published var favoriteProducts: [Product] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let userService = UserService.shared
    private let client = APIClient.shared
    private var cancellables = Set<AnyCancellable>()
    
    func loadFavorites() {
        // Evitar recargas innecesarias si ya estamos cargando
        guard !isLoading else { return }
        
        isLoading = true
        userService.fetchFavorites { [weak self] result in
            switch result {
            case .success(let ids):
                self?.hydrateProducts(ids: ids)
            case .failure:
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = "No se pudieron obtener tus favoritos"
                }
            }
        }
    }
    
    private func hydrateProducts(ids: [String]) {
        if ids.isEmpty {
            DispatchQueue.main.async {
                self.favoriteProducts = []
                self.isLoading = false
            }
            return
        }
        
        let group = DispatchGroup()
        var hydrated: [Product] = []
        let lock = NSLock()
        
        for id in ids {
            group.enter()
            client.execute(CoffeeEndpoint.productDetail(id: id)) { (result: Result<Product, APIError>) in
                if case .success(let product) = result {
                    lock.lock()
                    hydrated.append(product)
                    lock.unlock()
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            // Ordenar por nombre o mantener el orden original si el API lo garantiza
            self.favoriteProducts = hydrated.sorted(by: { $0.nombre < $1.nombre })
            self.isLoading = false
        }
    }
    
    func removeFavorite(id: String) {
        // Actualización optimista local
        withAnimation {
            favoriteProducts.removeAll { $0.id == id }
        }
        
        // Sincronizar con el API
        userService.toggleFavorite(productId: id) { [weak self] result in
            if case .failure = result {
                // Si falla, recargamos para asegurar consistencia
                self?.loadFavorites()
            }
        }
    }
}

// Extensión para facilitar animaciones en el ViewModel
import SwiftUI
