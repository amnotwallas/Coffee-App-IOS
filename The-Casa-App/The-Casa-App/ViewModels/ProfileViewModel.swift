import Foundation
import Combine
import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var updateSuccess: Bool = false
    
    private let userService = UserService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Observar cambios en el contexto global
        AppContext.shared.$currentUser
            .assign(to: \.userProfile, on: self)
            .store(in: &cancellables)
    }
    
    func loadProfile() {
        isLoading = true
        errorMessage = nil
        
        userService.fetchProfile { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                if case .failure(let error) = result {
                    self?.errorMessage = "Error al cargar perfil: \(error.message)"
                }
            }
        }
    }
    
    func updateInfo(nombre: String, telefono: String) {
        isLoading = true
        errorMessage = nil
        
        userService.updateProfile(nombre: nombre, telefono: telefono) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    self?.updateSuccess = true
                case .failure(let error):
                    self?.errorMessage = "No se pudo actualizar: \(error.message)"
                }
            }
        }
    }
    
    func deleteAddress(id: String) {
        // Actualización optimista local
        if var profile = userProfile, var addresses = profile.direcciones {
            addresses.removeAll { $0.id == id }
            // No podemos mutar profile.direcciones directamente si es let, 
            // pero el modelo UserProfile ya tiene direcciones como let.
            // El UserService.deleteAddress disparará un fetchProfile al terminar.
        }
        
        userService.deleteAddress(id: id) { [weak self] result in
            if case .failure(let error) = result {
                DispatchQueue.main.async {
                    self?.errorMessage = "No se pudo eliminar la dirección: \(error.message)"
                }
            }
        }
    }
    
    func logout() {
        AppContext.shared.logout()
    }
}
