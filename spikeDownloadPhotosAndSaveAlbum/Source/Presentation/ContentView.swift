//
//  ContentView.swift
//  spikeDownloadPhotosAndSaveAlbum
//
//  Created by David Martin Nevado on 12/2/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PhotoDownloadViewModel()

    var body: some View {
        VStack {
            Text("Download photos and create album")
                .font(.title)
                .multilineTextAlignment(.leading)
            
            Divider()

            VStack(alignment: .leading) {
                Text("Fill the album name")

                TextField("Ex. My Photos", text: $viewModel.albumName)
                    .padding()
                    .border(.gray)
            }

            HStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    Text("Fill the max images count")

                    TextField("Ex. 1000", text: $viewModel.maxImagesCount, prompt: Text("1000"))
                        .padding()
                        .border(.gray)
                }
                
                Button {
                    viewModel.downloadAndSaveImages()
                } label: {
                    Text(viewModel.isDownloading ? "Downloading..." : "Download")
                        .padding()
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(viewModel.isDownloading)
            }

            ProgressView(value: viewModel.progress,
                         total: Double(viewModel.maxImagesCount) ?? 1000) {
                if viewModel.progress > 0, viewModel.progress < 4 {
                    Text("Downloading...")
                }
            } currentValueLabel: {
                Text("Downloaded \(Int(viewModel.progress).description) of \(viewModel.imageCount) images")
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
