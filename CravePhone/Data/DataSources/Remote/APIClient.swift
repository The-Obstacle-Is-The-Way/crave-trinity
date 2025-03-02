//=================================================================
// 3) APIClient.swift
//    CravePhone/Data/DataSources/Remote/APIClient.swift
//=================================================================

import Foundation

public final class APIClient {

    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    /// Performs an OpenAI Chat request using the prompt & model.
    public func fetchOpenAIResponse(
        prompt: String,
        model: String = "gpt-4"
    ) async throws -> Data {

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw APIError.invalidEndpoint
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let apiKey = try SecretsManager.openAIAPIKey()
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode)
        else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw APIError.unexpectedStatusCode(code)
        }

        return data
    }
}

// MARK: - Supporting Errors
public enum APIError: Error, LocalizedError {
    case invalidEndpoint
    case unexpectedStatusCode(Int)

    public var errorDescription: String? {
        switch self {
        case .invalidEndpoint:
            return "Invalid OpenAI endpoint URL."
        case .unexpectedStatusCode(let code):
            return "Unexpected HTTP status code: \(code)"
        }
    }
}
