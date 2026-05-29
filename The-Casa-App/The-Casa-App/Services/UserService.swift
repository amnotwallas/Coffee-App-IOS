import Foundation

class UserService {
    static let shared = UserService()
    private let client = APIClient.shared
    private let context = AppContext.shared
    
    private init() {}
    
    func fetchProfile(completion: ((Result<UserProfile, APIError>) -> Void)? = nil) {
        client.execute(CoffeeEndpoint.getProfile) { [weak self] (result: Result<UserProfile, APIError>) in
            if case .success(let profile) = result {
                DispatchQueue.main.async {
                    self?.context.currentUser = profile
                    // También cargar favoritos automáticamente después de cargar el perfil
                    self?.fetchFavorites()
                }
            }
            completion?(result)
        }
    }
    
    func updateProfile(nombre: String?, telefono: String?, completion: @escaping (Result<UserProfile, APIError>) -> Void) {
        client.execute(CoffeeEndpoint.updateProfile(nombre: nombre, telefono: telefono)) { [weak self] (result: Result<UserProfile, APIError>) in
            if case .success(let profile) = result {
                DispatchQueue.main.async {
                    self?.context.currentUser = profile
                }
            }
            completion(result)
        }
    }
    
    func fetchAddresses(completion: @escaping (Result<[Address], APIError>) -> Void) {
        client.execute(CoffeeEndpoint.getAddresses, completion: completion)
    }
    
    func addAddress(calle: String, ciudad: String, codigoPostal: String, referencia: String?, esDefault: Bool, completion: @escaping (Result<Address, APIError>) -> Void) {
        client.execute(CoffeeEndpoint.addAddress(calle: calle, ciudad: ciudad, codigoPostal: codigoPostal, referencia: referencia, esDefault: esDefault)) { [weak self] (result: Result<Address, APIError>) in
            if case .success = result {
                // Refrescamos el perfil completo para tener la lista de direcciones actualizada en el contexto
                self?.fetchProfile()
            }
            completion(result)
        }
    }
    
    func deleteAddress(id: String, completion: @escaping (Result<MessageResponse, APIError>) -> Void) {
        client.execute(CoffeeEndpoint.deleteAddress(id: id)) { [weak self] (result: Result<MessageResponse, APIError>) in
            if case .success = result {
                // Refrescamos el perfil para actualizar la lista de direcciones
                self?.fetchProfile()
            }
            completion(result)
        }
    }
    
    // MARK: - Favorites
    
    func fetchFavorites(completion: ((Result<[String], APIError>) -> Void)? = nil) {
        client.execute(CoffeeEndpoint.getFavorites) { [weak self] (result: Result<[String], APIError>) in
            if case .success(let ids) = result {
                DispatchQueue.main.async {
                    self?.context.favoriteProductIds = Set(ids)
                }
            }
            completion?(result)
        }
    }
    
    func toggleFavorite(productId: String, completion: ((Result<Void, APIError>) -> Void)? = nil) {
        let isFavorite = context.favoriteProductIds.contains(productId)
        let endpoint = isFavorite ? CoffeeEndpoint.removeFavorite(productId: productId) : CoffeeEndpoint.addFavorite(productId: productId)
        
        // Actualización optimista
        DispatchQueue.main.async {
            if isFavorite {
                self.context.favoriteProductIds.remove(productId)
            } else {
                self.context.favoriteProductIds.insert(productId)
            }
        }
        
        client.execute(endpoint) { [weak self] (result: Result<MessageResponse, APIError>) in
            switch result {
            case .success:
                completion?(.success(()))
            case .failure(let error):
                // Revertir en caso de fallo
                DispatchQueue.main.async {
                    if isFavorite {
                        self?.context.favoriteProductIds.insert(productId)
                    } else {
                        self?.context.favoriteProductIds.remove(productId)
                    }
                }
                completion?(.failure(error))
            }
        }
    }
    
    // MARK: - Push Notifications
    
    func registerDeviceToken(_ token: String, completion: ((Result<MessageResponse, APIError>) -> Void)? = nil) {
        client.execute(CoffeeEndpoint.registerToken(token: token, platform: "ios")) { (result: Result<MessageResponse, APIError>) in
            completion?(result)
        }
    }
}
