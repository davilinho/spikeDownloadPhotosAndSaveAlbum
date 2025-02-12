//
//  PhotoDownloadViewModel.swift
//  spikeDownloadPhotosAndSaveAlbum
//
//  Created by David Martin Nevado on 12/2/25.
//

import SwiftUI
import Photos
import PhotosUI

@Observable class PhotoDownloadViewModel {
    var albumName: String = ""
    var isDownloading: Bool = false
    var progress: Double = 0.0
    var showError: Bool = false
    
    private let imageService: ImageServiceProtocol
    private let photoLibraryService: PhotoLibraryServiceProtocol
    
    let imageURLs = [
        "https://images.pexels.com/photos/674010/pexels-photo-674010.jpeg",
        "https://images.pexels.com/photos/3852204/pexels-photo-3852204.jpeg",
        "https://images.pexels.com/photos/3979134/pexels-photo-3979134.jpeg",
        "https://images.pexels.com/photos/3973089/pexels-photo-3973089.jpeg"
    ]
    
    init(imageService: ImageServiceProtocol, photoLibraryService: PhotoLibraryServiceProtocol) {
        self.imageService = imageService
        self.photoLibraryService = photoLibraryService
    }
    
    func downloadAndSaveImages() {
        guard !self.albumName.isEmpty else {
            self.showError = true
            return
        }
        self.isDownloading = true

        Task {
            let isGranted = await self.photoLibraryService.requestPermission()
            guard isGranted else {
                self.isDownloading = false
                return
            }
            await self.downloadImages()
        }
    }
    
    private func downloadImages() async {
        await withTaskGroup(of: Void.self) { group in
            self.imageURLs.forEach { urlString in
                group.addTask {
                    if let image = await self.imageService.downloadImage(from: urlString) {
                        do {
                            try await self.photoLibraryService.saveImage(image, to: self.albumName)
                            await MainActor.run {
                                self.progress += 1.0
                            }
                        } catch {
                            self.showError = true
                        }
                    }
                }
            }
        }

        await MainActor.run {
            self.isDownloading = false
            self.progress = 0.0
        }
    }
}
