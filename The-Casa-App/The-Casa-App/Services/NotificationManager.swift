import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    private let notificationService = NotificationService.shared
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestPermissions() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Permisos de notificación concedidos")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    
                    // Si estamos en simulador, Apple no nos dará un token real de APNs
                    // así que lo registramos manualmente aquí.
                    #if targetEnvironment(simulator)
                    self.registerSimulatorToken()
                    #endif
                }
            } else {
                print("❌ Permisos de notificación denegados")
            }
        }
    }
    
    func handleRegistration(withDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("🔑 APNs Token Real: \(tokenString)")
        registerTokenWithAPI(tokenString)
    }
    
    private func registerSimulatorToken() {
        let simToken = "SIM-\(UUID().uuidString.prefix(8))"
        print("🔑 Simulando Token para Backend: \(simToken)")
        registerTokenWithAPI(simToken)
    }
    
    private func registerTokenWithAPI(_ token: String) {
        notificationService.registerDeviceToken(token) { result in
            switch result {
            case .success:
                print("✅ Token registrado exitosamente en el servidor")
            case .failure(let error):
                print("❌ Error al registrar token en servidor: \(error.message)")
            }
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    // Recibir notificación cuando la app está en primer plano
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([[.banner, .sound, .badge]])
    }
}
