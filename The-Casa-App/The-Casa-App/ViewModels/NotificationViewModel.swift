import Foundation
import Combine
import AudioToolbox

class NotificationViewModel: ObservableObject {
    private let service = NotificationService.shared
    
    @Published var notifications: [CoffeeNotification] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var timer: AnyCancellable?
    private var lastUnreadCount: Int = 0
    
    var unreadCount: Int {
        notifications.filter { !$0.leida }.count
    }
    
    init() {
        // Ya no iniciamos polling automáticamente
    }
    
    func loadNotifications() {
        // Capa de seguridad: Si no hay token, no perdemos tiempo ni recursos
        guard TokenManager.shared.getToken() != nil else {
            print("👤 NotificationViewModel: Usuario invitado, cancelando consulta.")
            return
        }

        if notifications.isEmpty { isLoading = true }
        errorMessage = nil
        
        service.fetchNotifications { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let notifications):
                    // Solo mostramos las NO leídas para que "desaparezcan" al marcarlas
                    let unread = notifications.filter { !$0.leida }
                    
                    // Si hay nuevas notificaciones (conteo subió), hacemos sonido
                    if unread.count > self?.lastUnreadCount ?? 0 {
                        self?.playNotificationSound()
                    }
                    
                    self?.notifications = unread
                    self?.lastUnreadCount = unread.count
                case .failure(let error):
                    self?.errorMessage = error.message
                }
            }
        }
    }
    
    func markAsRead(notification: CoffeeNotification) {
        service.markAsRead(id: notification.id) { [weak self] result in
            if case .success = result {
                DispatchQueue.main.async {
                    // Eliminación instantánea local para UX fluida
                    self?.notifications.removeAll { $0.id == notification.id }
                    self?.lastUnreadCount = self?.notifications.count ?? 0
                }
            }
        }
    }
    
    func markAllAsRead() {
        service.markAllAsRead { [weak self] result in
            if case .success = result {
                DispatchQueue.main.async {
                    self?.notifications.removeAll()
                    self?.lastUnreadCount = 0
                }
            }
        }
    }
    
    func startPolling() {
        // Evitar duplicar timers
        stopPolling()
        
        // Carga inmediata al iniciar
        loadNotifications()
        
        // Consultar cada 5 segundos para mayor proactividad sin saturar
        timer = Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.loadNotifications()
            }
        print("🔔 Polling de notificaciones iniciado (10s).")
    }
    
    func refresh() {
        loadNotifications()
    }
    
    func stopPolling() {
        timer?.cancel()
        timer = nil
    }
    
    private func playNotificationSound() {
        // Sonido de sistema tipo "Tri-tone" o similar para avisos
        AudioServicesPlaySystemSound(1007)
    }
    
    deinit {
        timer?.cancel()
    }
}
