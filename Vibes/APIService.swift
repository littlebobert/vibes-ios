import Foundation
import UIKit

class APIService {
    static let shared = APIService()
    
    // Your ngrok URL - update this if it changes
    private let baseURL = "https://kaycee-soundable-unappeasingly.ngrok-free.dev"
    
    private init() {}
    
    func uploadPhoto(image: UIImage, name: String) async throws -> VibeResult {
        guard let url = URL(string: "\(baseURL)/api/upload") else {
            throw APIServiceError.invalidURL
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw APIServiceError.imageConversionFailed
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60 // AI analysis can take a moment
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add name field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(name)\r\n".data(using: .utf8)!)
        
        // Add photo field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIServiceError.invalidResponse
        }
        
        if httpResponse.statusCode == 200 {
            let decoder = JSONDecoder()
            return try decoder.decode(VibeResult.self, from: data)
        } else {
            // Try to parse error message
            if let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                throw APIServiceError.serverError(apiError.detail)
            }
            throw APIServiceError.serverError("Server returned status \(httpResponse.statusCode)")
        }
    }
    
    func healthCheck() async -> Bool {
        guard let url = URL(string: "\(baseURL)/api/health") else {
            return false
        }
        
        do {
            let (_, response) = try await URLSession.shared.data(from: url)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
}

enum APIServiceError: LocalizedError {
    case invalidURL
    case imageConversionFailed
    case invalidResponse
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid server URL"
        case .imageConversionFailed:
            return "Failed to process image"
        case .invalidResponse:
            return "Invalid server response"
        case .serverError(let message):
            return message
        }
    }
}
