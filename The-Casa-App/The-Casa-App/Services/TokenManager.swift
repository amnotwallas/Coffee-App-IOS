//
//  TokenManager.swift
//  The-Casa-App
//

import Foundation

class TokenManager {
    static let shared = TokenManager()
    private let tokenKey = "auth_token_client"
    
    private init() {}
    
    func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }
    
    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: tokenKey)
    }
    
    func clearToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
}
