import SwiftUI
import AVKit

struct MediaViewerView: View {
    var mediaURL: URL

    var body: some View {
        if mediaURL.pathExtension.lowercased().contains("mp4") {
            VideoPlayer(player: AVPlayer(url: mediaURL))
                .edgesIgnoringSafeArea(.all)
        } else {
            AsyncImage(url: mediaURL) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .edgesIgnoringSafeArea(.all)
                } else {
                    ProgressView()
                }
            }
        }
    }
}
