//
//  ContentView.swift
//  spikeDownloadPhotosAndSaveAlbum
//
//  Created by David Martin Nevado on 12/2/25.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel: PhotoDownloadViewModel

    init() {
        self.viewModel = PhotoDownloadViewModel(imageService: ImageService(), photoLibraryService: PhotoLibraryService())
    }

    var body: some View {
        VStack {
            Text("Download photos and save to Album Spike")
                .font(.title)

            HStack {
                TextField("Put the album name here", text: self.$viewModel.albumName)
                    .padding()
                    .border(.gray)
                
                Button {
                    self.viewModel.downloadAndSaveImages()
                } label: {
                    Text(self.viewModel.isDownloading ? "Downloading..." : "Download")
                        .padding()
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(self.viewModel.isDownloading)
            }

            ProgressView(value: self.viewModel.progress,
                         total: Double(self.viewModel.imageURLs.count)) {
                if self.viewModel.progress > 0, self.viewModel.progress < 4 {
                    Text("Downloading...")
                }
            } currentValueLabel: {
                Text("Downloaded \(Int(self.viewModel.progress).description) of \(self.viewModel.imageURLs.count) images")
            }
            .padding(.top, 32)
            
            Spacer()
        }
        .privacySensitive()
        .padding()
        .alert(isPresented: self.$viewModel.showError) {
            Alert(title: Text("No album name filled"),
                  message: Text("Is mandatory to put an album name to download photos and create the album"),
                  dismissButton: .default(Text("Close"), action: {}))
        }
    }
}

#Preview {
    ContentView()
}
