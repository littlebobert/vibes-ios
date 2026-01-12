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

struct DeleteResponse: Codable {
    let success: Bool
    let message: String
}

struct Submission: Codable, Identifiable {
    let id: String
    let name: String
    let photoFilename: String
    let vibeScore: Int
    let explanation: String
    let createdAt: String
    let photoUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case photoFilename = "photo_filename"
        case vibeScore = "vibe_score"
        case explanation
        case createdAt = "created_at"
        case photoUrl = "photo_url"
    }
}

// MARK: - App State

enum AppScreen {
    case namePrompt
    case camera
    case uploading
    case result(VibeResult)
    case error(String)
    case mySubmissions
}

// MARK: - User Defaults Keys

enum UserDefaultsKeys {
    static let userName = "vibes_user_name"
}
