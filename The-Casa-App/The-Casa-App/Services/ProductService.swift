import Foundation

class ProductService {
    static let shared = ProductService()
    private let client = APIClient.shared
    
    private init() {}
    
    func fetchProducts(category: Int? = nil, page: Int = 1, limit: Int = 10, completion: @escaping (Result<PaginatedProducts, APIError>) -> Void) {
        client.execute(CoffeeEndpoint.listProducts(category: category, page: page, limit: limit), completion: completion)
    }
    
    func getProductDetail(id: String, completion: @escaping (Result<Product, APIError>) -> Void) {
        client.execute(CoffeeEndpoint.productDetail(id: id), completion: completion)
    }
    
    func searchProducts(query: String, completion: @escaping (Result<SearchResponse, APIError>) -> Void) {
        client.execute(CoffeeEndpoint.searchProducts(query: query), completion: completion)
    }
}
