//
//  ImageServiceProtocol.swift
//  spikeDownloadPhotosAndSaveAlbum
//
//  Created by David Martin Nevado on 12/2/25.
//

import Foundation

struct User: Codable {
    let picture: Picture?

    struct Picture: Codable {
        let medium: String?
    }
}
