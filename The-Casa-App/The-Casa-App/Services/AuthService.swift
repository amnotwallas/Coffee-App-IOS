//
//  AuthService.swift
//  The-Casa-App
//

import FirebaseAuth
import GoogleSignIn

enum AuthError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case apiError(String)
}

struct FirebaseLoginResponse: Codable, Sendable {
    let idToken: String?
    let email: String?
}

struct FirebaseErrorResponse: Codable, Sendable {
    let error: FirebaseErrorDetails
}

struct FirebaseErrorDetails: Codable, Sendable {
    let message: String
}

struct AuthResponse: Codable, Sendable {
    let user: UserProfile?
    let access_token: String?
}

struct MessageResponse: Codable, Sendable {
    let message: String?
}

class AuthService {
    static let shared = AuthService()
    private init() {}
    
    func authenticate(email: String, password: String, completion: @escaping (Result<String, AuthError>) -> Void) {
        loginWithEmail(email: email, password: password, completion: completion)
    }
    
    /* 
    Paso para habilitar Google Login:
    1. Instalar via SPM: https://github.com/google/GoogleSignIn-iOS
    2. Instalar via SPM: https://github.com/firebase/firebase-ios-sdk
    3. Descomentar los imports arriba y el código de abajo.
    
    import FirebaseAuth
    import GoogleSignIn
    */
    
    func authenticateWithGoogle(presentingViewController: UIViewController, completion: @escaping (Result<String, AuthError>) -> Void) {
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { signInResult, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let user = signInResult?.user,
                  let idToken = user.idToken?.tokenString else {
                completion(.failure(.apiError("No se pudo obtener el token de Google")))
                return
            }
            
            let accessToken = user.accessToken.tokenString
            
            // 🔄 INTERCAMBIO: Usar credenciales de Google para entrar en Firebase
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    completion(.failure(.apiError("Error al sincronizar con Firebase: \(error.localizedDescription)")))
                    return
                }
                
                // Ahora pedimos el ID Token de FIREBASE (el que el servidor sí acepta)
                authResult?.user.getIDToken(completion: { token, error in
                    if let error = error {
                        completion(.failure(.apiError("No se pudo generar el token de sesión: \(error.localizedDescription)")))
                        return
                    }
                    
                    guard let firebaseToken = token else {
                        completion(.failure(.apiError("Token de sesión vacío")))
                        return
                    }
                    
                    print("✅ Firebase ID Token obtenido exitosamente")
                    completion(.success(firebaseToken))
                })
            }
        }
    }
    
    private func loginWithEmail(email: String, password: String, completion: @escaping (Result<String, AuthError>) -> Void) {
        let urlString = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=\(AppConfig.firebaseApiKey)"
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let body: [String: Any] = [
            "email": email,
            "password": password,
            "returnSecureToken": true
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidResponse))
                return
            }
            
            if let loginResponse = try? JSONDecoder().decode(FirebaseLoginResponse.self, from: data), let token = loginResponse.idToken {
                completion(.success(token))
            } else if let errorResponse = try? JSONDecoder().decode(FirebaseErrorResponse.self, from: data) {
                completion(.failure(.apiError(errorResponse.error.message)))
            } else {
                completion(.failure(.invalidResponse))
            }
        }.resume()
    }
    
    func verifyAndSyncWithAPI(firebaseToken: String, nombre: String? = nil, telefono: String? = nil, completion: @escaping (Result<String, AuthError>) -> Void) {
        let urlString = "\(AppConfig.baseURL)/auth/verify"
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var body: [String: Any] = [
            "firebase_token": firebaseToken
        ]
        
        if let nombre = nombre { body["nombre"] = nombre }
        if let telefono = telefono { body["telefono"] = telefono }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                if let apiResponse = try? JSONDecoder().decode(AuthResponse.self, from: data), let localToken = apiResponse.access_token {
                    completion(.success(localToken))
                } else {
                    completion(.failure(.invalidResponse))
                }
            } else {
                let rawError = String(data: data, encoding: .utf8) ?? "Sin respuesta del servidor"
                print("📡 [AUTH ERROR] RAW Response: \(rawError)")
                completion(.failure(.apiError("Error \(httpResponse.statusCode): \(rawError)")))
            }
        }.resume()
    }
}
