//
//  APIClient.swift
//  spikeDownloadPhotosAndSaveAlbum
//
//  Created by David Martin Nevado on 12/2/25.
//

protocol UserRepository {
    func fetchUsers(_ resource: Resource<UserResponse>) async throws -> UserResponse
}

class DefaultUserRepository: @unchecked Sendable, UserRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient = DefaultAPIClient()) {
        self.apiClient = apiClient
    }

    func fetchUsers(_ resource: Resource<UserResponse>) async throws -> UserResponse {
        try await self.apiClient.request(resource)
    }
}
