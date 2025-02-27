//
//  PhotoDownloadViewModel.swift
//  spikeDownloadPhotosAndSaveAlbum
//
//  Created by David Martin Nevado on 12/2/25.
//

import SwiftUI
import Photos
import PhotosUI

class PhotoDownloadViewModel: ObservableObject {
    @Published var albumName: String = ""
    @Published var isDownloading: Bool = false
    @Published var progress: Double = 0.0
    @Published var showError: Bool = false
    @Published var imageCount: Int = 0
    @Published var maxImagesCount: String = ""

    private var useCase: ListUsersUseCase
    private let imageService: ImageService
    private let photoLibraryService: PhotoLibraryService

    init(useCase: ListUsersUseCase = DefaultUsersUseCase(),
         imageService: ImageService = DefaultImageService(),
         photoLibraryService: PhotoLibraryService = DefaultPhotoLibraryService()) {
        self.useCase = useCase
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
            do {
                guard let resultsByPage = Int(self.maxImagesCount) else { return }
                
                let response = try await self.useCase.fetchUsers(resultsByPage: resultsByPage)
                
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.imageCount = response.entities.count
                }
                
                guard let album = try await self.photoLibraryService.fetchOrCreateAlbum(named: self.albumName) else { return }

                response.entities.forEach { entity in
                    group.addTask {
                        if let imageURL = entity.picture?.medium,
                           let image = await self.imageService.downloadImage(from: imageURL) {
                            do {
                                try await self.photoLibraryService.saveImage(image, to: album)
                                await MainActor.run { [weak self] in
                                    guard let self else { return }
                                    self.progress += 1.0
                                }
                            } catch {
                                self.showError = true
                            }
                        }
                    }
                }
            } catch {
                self.showError = true
            }
        }
        
        await MainActor.run {
            self.isDownloading = false
            self.progress = 0.0
        }
    }
}
