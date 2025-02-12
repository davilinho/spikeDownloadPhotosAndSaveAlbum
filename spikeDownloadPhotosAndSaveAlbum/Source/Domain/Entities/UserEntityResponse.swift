//
//  ImageServiceProtocol.swift
//  spikeDownloadPhotosAndSaveAlbum
//
//  Created by David Martin Nevado on 12/2/25.
//

class UserEntityResponse: @unchecked Sendable {
    var entities: [User] = []
    var info: Info?

    init(entities: [User], info: Info? = nil) {
        self.entities = entities
        self.info = info
    }
}
