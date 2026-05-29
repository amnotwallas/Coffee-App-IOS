import Foundation
import Combine
import SwiftUI

class AppContext: ObservableObject {
    static let shared = AppContext()
    
    @Published var currentUser: UserProfile?
    @Published var activeCart: Cart?
    @Published var favoriteProductIds: Set<String> = []
    @Published var isLoading: Bool = false
    @Published var showLoginPrompt: Bool = false
    @Published var shouldNavigateToLogin: Bool = false
    
    // Feedback Global (Toasts)
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    @Published var addedProductImageUrl: String? = nil
    
    private init() {}
    
    func showFeedback(_ message: String, imageUrl: String? = nil) {
        guard !message.isEmpty else { return }
        
        DispatchQueue.main.async {
            // Cancelar cualquier ocultación previa
            self.showToast = false
            
            // Pequeño respiro para que el cerebro note el cambio de estado
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.toastMessage = message
                self.addedProductImageUrl = imageUrl
                
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)) {
                    self.showToast = true
                }
            }
            
            // Ocultar automáticamente después de 5 segundos
            let id = UUID()
            self.lastToastId = id
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                if self.lastToastId == id {
                    withAnimation(.spring()) {
                        self.showToast = false
                    }
                }
            }
        }
    }
    
    private var lastToastId: UUID? = nil
    
    func logout() {
        // Activar pantalla de carga global
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        // Pequeño delay para simular limpieza y que se vea el logo respirando
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.currentUser = nil
            self.activeCart = nil
            self.favoriteProductIds = []
            TokenManager.shared.clearToken()
            
            // Notificar para forzar el cambio de pantalla
            self.shouldNavigateToLogin = true
            self.isLoading = false
        }
    }
}
