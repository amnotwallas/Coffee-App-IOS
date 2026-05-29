import Foundation
import Combine

class OrderHistoryViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let orderService = OrderService.shared
    
    func loadOrders() {
        isLoading = true
        errorMessage = nil
        
        orderService.fetchOrders { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let orders):
                    // Ordenar por fecha descendente (más recientes primero)
                    self?.orders = orders.sorted(by: { $0.fecha > $1.fecha })
                case .failure(let error):
                    self?.errorMessage = "No pudimos cargar tus pedidos: \(error.message)"
                }
            }
        }
    }
}
