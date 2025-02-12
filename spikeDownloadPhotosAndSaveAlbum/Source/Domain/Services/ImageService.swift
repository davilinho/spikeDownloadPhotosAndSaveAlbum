//
//  ImageService.swift
//  spikeDownloadPhotosAndSaveAlbum
//
//  Created by David Martin Nevado on 12/2/25.
//

import SwiftUI

protocol ImageService: Sendable {
    func downloadImage(from urlString: String) async -> UIImage?
}

actor DefaultImageService: ImageService {
    func downloadImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return UIImage(data: data)
    }
}
