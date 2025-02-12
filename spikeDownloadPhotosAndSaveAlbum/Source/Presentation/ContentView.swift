//
//  ContentView.swift
//  spikeDownloadPhotosAndSaveAlbum
//
//  Created by David Martin Nevado on 12/2/25.
//

import Photos
import PhotosUI
import SwiftUI

struct ContentView: View {
    @State private var albumName: String = ""
    @State private var showError: Bool = false
    @State private var isDownloading: Bool = false
    @State private var progress: Double = 0.0
    
    private let imageURLs = [
        "https://images.pexels.com/photos/674010/pexels-photo-674010.jpeg",
        "https://images.pexels.com/photos/3852204/pexels-photo-3852204.jpeg",
        "https://images.pexels.com/photos/3979134/pexels-photo-3979134.jpeg",
        "https://images.pexels.com/photos/3973089/pexels-photo-3973089.jpeg"
    ]

    var body: some View {
        VStack {
            Text("Download photos and save to Album Spike")
                .font(.title)

            HStack {
                TextField("Put the album name here", text: self.$albumName)
                    .padding()
                    .border(.gray)
                
                Button(action: self.downloadAndSaveImages) {
                    Text(self.isDownloading ? "Downloading..." : "Download")
                        .padding()
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(self.isDownloading)
            }

            ProgressView(value: self.progress, total: Double(self.imageURLs.count)) {
                if self.progress > 0, self.progress < 4 {
                    Text("Downloading...")
                }
            } currentValueLabel: {
                Text("Downloaded \(Int(self.progress).description) of \(self.imageURLs.count) images")
            }
            .padding(.top, 32)
            
            Spacer()
        }
        .privacySensitive()
        .padding()
        .alert(isPresented: self.$showError) {
            Alert(title: Text("No album name filled"),
                  message: Text("Is mandatory to put an album name to download photos and create the album"),
                  dismissButton: .default(Text("Close"), action: {}))
        }
    }
    
    private func downloadAndSaveImages() {
        if self.albumName.isEmpty {
            withAnimation {
                self.showError = true
            }
        } else {
            withAnimation {
                self.showError = false
                self.isDownloading = true
            }
            self.requestPhotoLibraryPermission { granted in
                guard granted else {
                    withAnimation {
                        self.isDownloading = false
                    }
                    return
                }
                
                Task {
                    await self.downloadImages()
                }
            }
        }
    }
    
    private func downloadImages() async {
        await withTaskGroup(of: Void.self) { group in
            self.imageURLs.forEach { urlString in
                group.addTask {
                    if let url = URL(string: urlString),
                       let data = try? Data(contentsOf: url),
                       let image = UIImage(data: data) {
                        await self.saveImageToAlbum(image)
                    }
                }
            }
        }
        self.isDownloading = false
        self.progress = 0.0
    }
    
    private func saveImageToAlbum(_ image: UIImage) async {
        guard !self.albumName.isEmpty,
              let album = self.fetchOrCreateAlbum(named: self.albumName) else {
            return
        }
        
        PHPhotoLibrary.shared().performChanges {
            let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
            let assetPlaceholder = request.placeholderForCreatedAsset
            albumChangeRequest?.addAssets([assetPlaceholder as Any] as NSArray)
        } completionHandler: { success, error in
            if success {
                DispatchQueue.main.async {
                    self.progress += 1.0
                }
            }
        }
    }
    
    private func fetchOrCreateAlbum(named name: String) -> PHAssetCollection? {
        do {
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
        } catch {
            return nil
        }
    }
    
    private func requestPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                completion(newStatus == .authorized || newStatus == .limited)
            }
        default:
            completion(false)
        }
    }
}

#Preview {
    ContentView()
}
