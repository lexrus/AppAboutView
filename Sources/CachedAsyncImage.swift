import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// A view that asynchronously loads and caches images from a URL
public struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let urlString: String
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder

    @State private var image: Image?
    @State private var isLoading = false

    public init(
        urlString: String,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.urlString = urlString
        self.content = content
        self.placeholder = placeholder
    }

    public var body: some View {
        Group {
            if let image = image {
                content(image)
            } else {
                placeholder()
            }
        }
        .task {
            await loadImage()
        }
    }

    private func loadImage() async {
        guard !isLoading else { return }
        isLoading = true

        if let platformImage = await ImageCache.shared.loadImage(from: urlString) {
            #if canImport(UIKit)
            image = Image(uiImage: platformImage)
            #elseif canImport(AppKit)
            image = Image(nsImage: platformImage)
            #endif
        }

        isLoading = false
    }
}

// Convenience initializer for simple use cases
extension CachedAsyncImage where Content == Image, Placeholder == Color {
    public init(urlString: String) {
        self.init(
            urlString: urlString,
            content: { image in
                image
            },
            placeholder: {
                Color.clear
            }
        )
    }
}
