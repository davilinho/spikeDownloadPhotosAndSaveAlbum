//
//  APIClient.swift
//  spikeDownloadPhotosAndSaveAlbum
//
//  Created by David Martin Nevado on 12/2/25.
//

import Foundation

extension URL {
    private enum Constants {
        // Components
        static let scheme = "https"
        static let host = "randomuser.me"
        static let path = "/api/"

        // Query items
        static let include = "inc"
        static let includeItems = "picture"
        static let page = "page"
        static let pageNumber = "1"
        static let results = "results"
        static let seed = "seed"
    }

    static func fetch(resultsByPage: Int) throws -> URL? {
        var components = URLComponents()
        components.scheme = Constants.scheme
        components.host = Constants.host
        components.path = Constants.path

        components.queryItems = [
            URLQueryItem(name: Constants.include, value: Constants.includeItems),
            URLQueryItem(name: Constants.page, value: Constants.pageNumber),
            URLQueryItem(name: Constants.results, value: String(resultsByPage)),
            URLQueryItem(name: Constants.seed, value: generateRandomSeek)
        ]

        guard let url = components.url else {
            throw NetworkError.badUrl
        }

        return url
    }
    
    static var generateRandomSeek: String {
        String((0..<16).compactMap { _ in "0123456789abcdef".randomElement() })
    }
}

