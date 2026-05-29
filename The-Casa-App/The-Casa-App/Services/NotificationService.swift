import Foundation

class NotificationService {
    static let shared = NotificationService()
    private let client = APIClient.shared
    
    private init() {}
    
    func fetchNotifications(completion: @escaping (Result<[CoffeeNotification], APIError>) -> Void) {
        client.execute(CoffeeEndpoint.getNotifications, completion: completion)
    }
    
    func markAsRead(id: String, completion: @escaping (Result<MessageResponse, APIError>) -> Void) {
        client.execute(CoffeeEndpoint.markNotificationRead(id: id), completion: completion)
    }
    
    func markAllAsRead(completion: @escaping (Result<MessageResponse, APIError>) -> Void) {
        client.execute(CoffeeEndpoint.markAllNotificationsRead, completion: completion)
    }
    
    func registerDeviceToken(_ token: String, completion: ((Result<MessageResponse, APIError>) -> Void)? = nil) {
        client.execute(CoffeeEndpoint.registerToken(token: token, platform: "ios")) { (result: Result<MessageResponse, APIError>) in
            completion?(result)
        }
    }
}
