import Foundation
import Combine

class CatalogViewModel: ObservableObject {
    private let productService = ProductService.shared
    private let cartService = CartService.shared
    
    @Published var products: [Product] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedCategoryId: Int? = 1 // Default: Bebidas Frías
    @Published var searchQuery: String = ""
    
    // Caché local para evitar parpadeos al cambiar entre categorías ya cargadas
    private var categoryCache: [Int: [Product]] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSearchDebounce()
    }
    
    private func setupSearchDebounce() {
        $searchQuery
            .dropFirst()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                if query.isEmpty {
                    self?.displaySelectedCategory()
                } else {
                    self?.performSearch(query: query)
                }
            }
            .store(in: &cancellables)
    }
    
    private var hasPreloaded = false
    
    func loadProducts() {
        // Si ya pre-cargamos, solo nos aseguramos de mostrar la categoría actual
        if hasPreloaded {
            displaySelectedCategory()
            return
        }
        
        let categoriesToPreload = [1, 2, 3, 4, 5]
        isLoading = true
        hasPreloaded = true
        
        let group = DispatchGroup()
        
        for catId in categoriesToPreload {
            group.enter()
            productService.fetchProducts(category: catId) { [weak self] result in
                if case .success(let paginated) = result {
                    self?.categoryCache[catId] = paginated.data
                    self?.preloadImages(for: paginated.data)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.isLoading = false
            self.displaySelectedCategory()
        }
    }
    
    private func preloadImages(for products: [Product]) {
        for product in products {
            guard let urlString = product.principalImagenUrl, let url = URL(string: urlString) else { continue }
            
            // Usamos URLSession para descargar la imagen en segundo plano. 
            // Esto la coloca en el URLCache del sistema, que AsyncImage usa automáticamente.
            URLSession.shared.dataTask(with: url).resume()
        }
    }
    
    func selectCategory(_ id: Int) {
        selectedCategoryId = id
        searchQuery = ""
        displaySelectedCategory()
        
        // Si por alguna razón no está en caché, lo intentamos cargar
        if categoryCache[id] == nil {
            isLoading = true
            productService.fetchProducts(category: id) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if case .success(let paginated) = result {
                        self?.categoryCache[id] = paginated.data
                        if self?.selectedCategoryId == id {
                            self?.products = paginated.data
                        }
                    }
                }
            }
        }
    }
    
    private func displaySelectedCategory() {
        guard let catId = selectedCategoryId else { return }
        if let cachedProducts = categoryCache[catId] {
            self.products = cachedProducts
        }
    }
    
    private func performSearch(query: String) {
        isLoading = true
        productService.searchProducts(query: query) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    self?.products = response.results
                case .failure(let error):
                    self?.errorMessage = error.message
                }
            }
        }
    }
}
