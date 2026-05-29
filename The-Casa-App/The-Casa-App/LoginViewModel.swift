//
//  LoginViewModel.swift
//  The-Casa-App
//
//  Created by Walter Jahir Ambriz Reyna on 12/05/26.
//

import Foundation
import UIKit

class LoginViewModel {
    
    // MARK: - Properties
    private let authService = AuthService.shared
    
    // Estado para autenticación en múltiples pasos
    var pendingFirebaseToken: String?
    
    // Callbacks para la vista
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onLoginSuccess: (() -> Void)?
    var onRequireProfileCompletion: (() -> Void)?
    
    var isLoading: Bool = false {
        didSet { onLoadingStateChanged?(isLoading) }
    }
    
    // MARK: - Actions
    func login(email: String, password: String) {
        isLoading = true
        print("👤 Iniciando login con Email...")
        
        authService.authenticate(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    print("✅ Token de Firebase obtenido")
                    self?.pendingFirebaseToken = token
                    self?.finalizeRegistrationSilently()
                case .failure(let error):
                    print("❌ Error en auth de Firebase: \(error)")
                    self?.isLoading = false
                    self?.handleError(error)
                }
            }
        }
    }
    
    func handleGoogleLogin(presentingViewController: UIViewController) {
        isLoading = true
        print("👤 Iniciando login con Google...")
        
        authService.authenticateWithGoogle(presentingViewController: presentingViewController) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    print("✅ Token de Google obtenido: \(token)")
                    self?.pendingFirebaseToken = token
                    self?.finalizeRegistrationSilently()
                case .failure(let error):
                    print("❌ Error en Google Login: \(error)")
                    self?.isLoading = false
                    self?.handleError(error)
                }
            }
        }
    }
    
    private func finalizeRegistrationSilently() {
        guard let token = pendingFirebaseToken else {
            print("⚠️ No hay token pendiente para verificar")
            isLoading = false
            return
        }
        
        print("📡 Verificando token con el API...")
        authService.verifyAndSyncWithAPI(firebaseToken: token) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let apiToken):
                    print("✅ API Verificada. Guardando JWT Local.")
                    TokenManager.shared.saveToken(apiToken)
                    self?.onLoginSuccess?()
                case .failure(let error):
                    print("❌ Error en verificación de API: \(error)")
                    self?.handleError(error)
                }
            }
        }
    }
    
    func finalizeRegistration(nombre: String, telefono: String) {
        // Este método se mantiene por si se usa desde una vista de edición,
        // pero el flujo principal ahora usa finalizeRegistrationSilently
        guard let token = pendingFirebaseToken else {
            onError?("No hay token de autenticación pendiente")
            return
        }
        
        isLoading = true
        authService.verifyAndSyncWithAPI(firebaseToken: token, nombre: nombre, telefono: telefono) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let apiToken):
                    TokenManager.shared.saveToken(apiToken)
                    self?.onLoginSuccess?()
                case .failure(let error):
                    self?.handleError(error)
                }
            }
        }
    }
    
    private func handleError(_ error: AuthError) {
        let message: String
        switch error {
        case .apiError(let msg): message = msg
        case .networkError(_): message = "Error de conexión o cancelación"
        default: message = "Error inesperado en la autenticación"
        }
        onError?(message)
    }
    
    func handleSkip() {
        print("Usuario decidió saltar el login")
        onLoginSuccess?()
    }
    
    func handleRegister() {
        print("Navegar a Registro")
    }
    
    func handleLogin() {
        print("Navegar a Inicio de Sesión")
    }
}
