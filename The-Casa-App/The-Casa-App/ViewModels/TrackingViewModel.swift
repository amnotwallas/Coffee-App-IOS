import Foundation
import Combine

class TrackingViewModel: ObservableObject {
    @Published var tracking: OrderTracking?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let orderService = OrderService.shared
    private var timer: AnyCancellable?
    private let orderId: String
    
    init(orderId: String) {
        self.orderId = orderId
        print("📍 Iniciando rastreo para pedido: \(orderId)")
        startPolling()
    }
    
    func fetchStatus() {
        // Solo mostramos loading la primera vez para no parpadear el UI en polling
        if tracking == nil { isLoading = true }
        
        orderService.fetchOrderTracking(orderId: orderId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let data):
                    self?.tracking = data
                    print("🔄 Tracking actualizado: P:\(data.preparando) L:\(data.listo) E:\(data.entregado)")
                    
                    // Detener polling si ya se entregó
                    if data.entregado {
                        print("✅ Pedido entregado, deteniendo polling.")
                        self?.timer?.cancel()
                    }
                case .failure(let error):
                    print("⚠️ Error en polling de tracking: \(error.message)")
                    // No mostramos error persistente en polling para no molestar
                }
            }
        }
    }
    
    private func startPolling() {
        fetchStatus() // Primera carga inmediata
        
        // Configurar timer cada 30 segundos
        timer = Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchStatus()
            }
    }
    
    deinit {
        timer?.cancel()
    }
}
