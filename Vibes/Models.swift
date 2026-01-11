import Foundation

// MARK: - API Response Models

struct VibeResult: Codable {
    let id: String
    let name: String
    let vibeScore: Int
    let explanation: String
    let photoUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case vibeScore = "vibe_score"
        case explanation
        case photoUrl = "photo_url"
    }
}

struct APIError: Codable {
    let detail: String
}

// MARK: - App State

enum AppScreen {
    case namePrompt
    case camera
    case uploading
    case result(VibeResult)
    case error(String)
}

// MARK: - User Defaults Keys

enum UserDefaultsKeys {
    static let userName = "vibes_user_name"
}
