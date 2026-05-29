import Foundation

struct ChatMessageResponse: Codable {
    let conversationId: String
    let suggestions: [String]?
}

struct WelcomeResponse: Codable {
    let message: String
    let recommendations: [Product]
    let conversationId: String
}

struct ChatRecommendationRequest: Codable {
    let preferences: [String]
}
