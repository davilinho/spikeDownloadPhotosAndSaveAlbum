//
//  ImageServiceProtocol.swift
//  spikeDownloadPhotosAndSaveAlbum
//
//  Created by David Martin Nevado on 12/2/25.
//

import Foundation

struct Info: Codable, Sendable {
    let seed: String?
    let results: Int
    let page: Int
    let version: String
}
