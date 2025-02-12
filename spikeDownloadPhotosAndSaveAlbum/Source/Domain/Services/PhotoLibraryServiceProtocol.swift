//
//  PhotoLibraryServiceProtocol.swift
//  spikeDownloadPhotosAndSaveAlbum
//
//  Created by David Martin Nevado on 12/2/25.
//

import SwiftUI
import Photos
import PhotosUI

protocol PhotoLibraryServiceProtocol {
    func requestPermission() async -> Bool
    func saveImage(_ image: UIImage, to albumName: String) async throws
}

class PhotoLibraryService: PhotoLibraryServiceProtocol {
    func requestPermission() async -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            return true
        case .notDetermined:
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            return newStatus == .authorized || newStatus == .limited
        default:
            return false
        }
    }
    
    func saveImage(_ image: UIImage, to albumName: String) async throws {
        guard let album = try self.fetchOrCreateAlbum(named: albumName) else { return }

        try await PHPhotoLibrary.shared().performChanges {
            let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
            let assetPlaceholder = request.placeholderForCreatedAsset
            albumChangeRequest?.addAssets([assetPlaceholder as Any] as NSArray)
        }
    }
    
    private func fetchOrCreateAlbum(named name: String) throws -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "localizedTitle = %@", name)

        if let existingAlbum = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions).firstObject {
            return existingAlbum
        }

        var albumPlaceholder: PHObjectPlaceholder?
        try PHPhotoLibrary.shared().performChangesAndWait {
            let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
            albumPlaceholder = request.placeholderForCreatedAssetCollection
        }
        
        if let placeholder = albumPlaceholder {
            return PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil).firstObject
        }

        return nil
    }
}
