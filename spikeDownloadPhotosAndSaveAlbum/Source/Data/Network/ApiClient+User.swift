//
//  APIClient.swift
//  spikeDownloadPhotosAndSaveAlbum
//
//  Created by David Martin Nevado on 12/2/25.
//

import Foundation

struct UserResponse: Codable, Sendable {
    let results: [User]
    let info: Info

    static func get(resultsByPage: Int) throws -> Resource<UserResponse> {
        guard let url = try URL.fetch(resultsByPage: resultsByPage) else {
            throw NetworkError.badUrl
        }
        return Resource(url: url)
    }
}
