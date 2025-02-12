//
//  APIClient.swift
//  spikeDownloadPhotosAndSaveAlbum
//
//  Created by David Martin Nevado on 12/2/25.
//

protocol ListUsersUseCase: Sendable {
    func fetchUsers(resultsByPage: Int) async throws -> UserEntityResponse
}

actor DefaultUsersUseCase: ListUsersUseCase {
    private let repository: UserRepository

    init(repository: UserRepository = DefaultUserRepository()) {
        self.repository = repository
    }

    func fetchUsers(resultsByPage: Int) async throws -> UserEntityResponse {
        let resource = try UserResponse.get(resultsByPage: resultsByPage)
        let response = try await self.repository.fetchUsers(resource)
        let entities = response.results
        let info = response.info

        if entities.isEmpty {
            throw DomainError.notFound
        }

        return UserEntityResponse(entities: entities, info: info)
    }
}
