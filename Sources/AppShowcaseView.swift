import SwiftUI

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

#if canImport(StoreKit)
import StoreKit
#endif

public struct AppShowcaseView: View {
    @StateObject private var showcaseService: AppShowcaseService

    public init(remoteURL: URL? = nil, currentAppStoreID: String? = nil) {
        _showcaseService = StateObject(wrappedValue: AppShowcaseService(remoteURL: remoteURL, currentAppStoreID: currentAppStoreID))
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            #if os(macOS)
            HStack(alignment: .center) {
                Spacer()
                Text(String(localized: "AppAboutView.MyApps", bundle: .module))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .opacity(0.5)
                Spacer()
            }
            #endif

            if showcaseService.apps.isEmpty {
                EmptyStateView()
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(Array(showcaseService.apps.enumerated()), id: \.element.id) { index, app in
                        AppShowcaseItemView(app: app) {
                            openAppStore(for: app)
                        }

                        if index < showcaseService.apps.count - 1 {
                            Divider()
                                .opacity(0.5)
                                .padding(.init(top: 4, leading: 52, bottom: 4, trailing: 0))
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .onAppear {
            showcaseService.fetchRemoteAppsIfNeeded()
        }
    }

    private func openAppStore(for app: MyAppInfo) {
#if os(macOS)
        let urlString = "https://apps.apple.com/app/id\(app.appStoreID)"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
#elseif os(iOS)
        let storeViewController = SKStoreProductViewController()
        storeViewController.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: app.appStoreID]) { _, _ in }

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(storeViewController, animated: true)
        }
#elseif os(tvOS) || os(visionOS)
        let urlString = "https://apps.apple.com/app/id\(app.appStoreID)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
#endif
    }
}

struct AppShowcaseItemView: View {
    let app: MyAppInfo
    let onTap: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // App Icon
                VStack {
                    appIconView()
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(app.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .shadow(
                            color: isHovered ? Color.blue.opacity(0.5) : .clear,
                            radius: isHovered ? 5 : 0,
                            x: 0,
                            y: 1
                        )
                        .animation(.easeInOut(duration: 0.15), value: isHovered)

                    Text(app.briefDescription.localizedString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(5)

                    // Platform tags
                    HStack(spacing: 6) {
                        ForEach(app.platforms, id: \.self) { platform in
                            PlatformTagView(platform: platform)
                        }
                        Spacer()
                    }
                }

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
#if os(macOS)
        .onHover { hovering in
            isHovered = hovering
        }
#elseif os(iOS)
        .onHoverIfAvailable { hovering in
            isHovered = hovering
        }
#endif
    }

    @ViewBuilder
    private func appIconView() -> some View {
        let size: CGFloat = 40
        let cornerRadius: CGFloat = 8
        let shadowColor = isHovered ? Color.blue.opacity(0.3) : Color.black.opacity(0.15)

        iconContent()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(
                color: shadowColor,
                radius: isHovered ? 10 : 3,
                x: 0,
                y: isHovered ? 5 : 1
            )
            .animation(.easeInOut(duration: 0.15), value: isHovered)
    }

    @ViewBuilder
    private func iconContent() -> some View {
        if let iconURL = app.iconURL {
            CachedAsyncImage(
                urlString: iconURL,
                content: { image in
                    image
                        .resizable()
                        .interpolation(.high)
                        .scaledToFill()
                },
                placeholder: {
                    placeholderSymbol()
                }
            )
        } else {
            localIconOrPlaceholder()
        }
    }

    @ViewBuilder
    private func localIconOrPlaceholder() -> some View {
        if let image = loadLocalAppIcon() {
            image
                .resizable()
                .scaledToFill()
        } else {
            placeholderSymbol()
        }
    }

    @ViewBuilder
    private func placeholderSymbol() -> some View {
        Image(systemName: "app.fill")
            .resizable()
            .frame(width: 36, height: 36)
            .foregroundColor(.secondary.opacity(0.1))
    }

    private func loadLocalAppIcon() -> Image? {
        let iconName = "\(app.id)-icon"

        // Try to load from local bundle first
#if canImport(UIKit)
        if let image = UIImage(named: iconName, in: .module, compatibleWith: nil) {
            return Image(uiImage: image)
        }
#endif

#if canImport(AppKit)
        #if targetEnvironment(macCatalyst)
        // Use UIImage for Mac Catalyst
        if let image = UIImage(named: iconName, in: .module, compatibleWith: nil) {
            return Image(uiImage: image)
        }
        #else
        // Use NSImage for native macOS
        if let image = Bundle.module.image(forResource: iconName) {
            return Image(nsImage: image)
        }
        #endif
#endif

        return nil
    }
}

struct PlatformTagView: View {
    let platform: Platform

    var body: some View {
        Image(systemName: platform.systemImageName)
            .font(.system(size: 10))
            .foregroundColor(.secondary)
            .frame(width: 12, height: 12)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 24))
                .foregroundColor(.secondary)

            Text(String(localized: "AppAboutView.NoAppsFound", bundle: .module))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}


#Preview {
    ZStack {
        AppShowcaseView(
            remoteURL: URL(string: "https://lex.sh/apps/apps.json"),
//            currentAppStoreID: "6748440814"
        ) // Test filtering with Sharptooth's ID
            .frame(width: 400, height: 500)
    }
    .padding()
}

#if os(iOS)
private extension View {
    @ViewBuilder
    func onHoverIfAvailable(_ action: @escaping (Bool) -> Void) -> some View {
        if #available(iOS 13.4, *) {
            onHover(perform: action)
        } else {
            self
        }
    }
}
#endif
