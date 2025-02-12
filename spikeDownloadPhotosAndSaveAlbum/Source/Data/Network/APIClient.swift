//
//  APIClient.swift
//  spikeDownloadPhotosAndSaveAlbum
//
//  Created by David Martin Nevado on 12/2/25.
//

import Foundation

protocol APIClient: Sendable {
    func request<T>(_ resource: Resource<T>) async throws -> T where T : Decodable & Sendable
}

protocol URLSessionProtocol: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

let validStatus = 200...299

actor DefaultAPIClient: APIClient {
    private let session: URLSessionProtocol

    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }

    func request<T>(_ resource: Resource<T>) async throws -> T where T : Decodable & Sendable {
        var request = URLRequest(url: resource.url)
        request.allHTTPHeaderFields = resource.headers

        switch resource.method {
        case .post(let data):
            request.httpMethod = resource.method.name
            request.httpBody = data
        case .get:
            let components = URLComponents(url: resource.url, resolvingAgainstBaseURL: false)
            guard let url = components?.url else {
                throw NetworkError.badUrl
            }
            request = URLRequest(url: url)
        }

        let (data, response) = try await self.session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              validStatus.contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }

        guard let result = try? JSONDecoder().decode(T.self, from: data) else {
            throw NetworkError.decodingError
        }

        return result
    }
}

struct Resource<T: Codable> {
    let url: URL
    var headers: [String: String] = ["Content-Type": "application/json"]
    var method: HttpMethod = .get
}
