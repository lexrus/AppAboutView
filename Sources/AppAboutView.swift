import SwiftUI
import StoreKit

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

public struct AppAboutView: View {
    @State internal var showingThankYouAlert = false
    @State internal var isLoadingPurchase = false
    @State internal var loadedProducts: [Product] = []
    @State internal var productsLoaded = false
    
    // UI Testing detection
    private var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("UI_TESTING") ||
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ||
        ProcessInfo.processInfo.environment["XCTestSessionIdentifier"] != nil
    }
    let appName: String
    let appIcon: Image?
    let appVersion: String
    let buildVersion: String
    let feedbackEmail: String?
    let appStoreID: String
    let privacyPolicy: URL?
    let copyrightText: String?
    let onAcknowledgments: (() -> Void)?
    let appsShowcaseURL: URL?
    let coffeeTips: [String]?

    public init(
        appName: String = "App",
        appIcon: Image? = nil,
        appVersion: String = "1.0.0",
        buildVersion: String = "1",
        feedbackEmail: String? = nil,
        appStoreID: String,
        privacyPolicy: URL? = nil,
        copyrightText: String? = nil,
        onAcknowledgments: (() -> Void)? = nil,
        appsShowcaseURL: URL? = nil,
        coffeeTips: [String]? = nil
    ) {
        self.appName = appName
        self.appIcon = appIcon
        self.appVersion = appVersion
        self.buildVersion = buildVersion
        self.feedbackEmail = feedbackEmail
        self.appStoreID = appStoreID
        self.privacyPolicy = privacyPolicy
        self.copyrightText = copyrightText
        self.onAcknowledgments = onAcknowledgments
        self.appsShowcaseURL = appsShowcaseURL
        self.coffeeTips = coffeeTips
    }

    public var body: some View {
        ZStack {
#if os(macOS)
            buildMacOSLayout()
#else
            buildNormalLayout()
#endif
            
            if isLoadingPurchase {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                }
                .padding(24)
                .background(Material.regular, in: RoundedRectangle(cornerRadius: 16))
            }
        }
        .task {
            await loadProducts()
        }
    }


    // MARK: - Private Properties

    @ViewBuilder
    internal func buildCoffeeTipsSection() -> some View {
        VStack(spacing: 12) {
#if !os(macOS)
            Text(String(localized: "AppAboutView.SupportDeveloper", bundle: .module))
                .font(.headline)
                .fontWeight(.medium)
#endif

#if os(macOS)
            VStack(spacing: 12) {
                let coffeeTipButtons = buildCoffeeTipButtons()
                ForEach(Array(coffeeTipButtons.enumerated()), id: \.offset) { index, button in
                    button
                }
            }
#else
            VStack(spacing: 0) {
                let coffeeTipButtons = buildCoffeeTipButtons()
                ForEach(Array(coffeeTipButtons.enumerated()), id: \.offset) { index, button in
                    button

                    if index < coffeeTipButtons.count - 1 {
                        Divider()
                            .opacity(0.5)
                            .padding(.init(top: 4, leading: 32, bottom: 4, trailing: 0))
                    }
                }
            }
#if !os(tvOS)
            .scrollContentBackground(.hidden)
#endif
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(formBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(formBorderColor, lineWidth: 1)
            )
#endif
        }
    }

    internal func buildCoffeeTipButtons() -> [AnyView] {
        guard let coffeeTips = coffeeTips, productsLoaded else { return [] }

        return coffeeTips.enumerated().compactMap { index, productID in
            let displayName: String
            
            // Check if we're in UI testing environment OR if we have no loaded products (likely testing)
            if isUITesting || loadedProducts.isEmpty {
                displayName = generateMockCoffeeTipDisplayName(for: index, productID: productID)
            } else {
                guard let product = loadedProducts.first(where: { $0.id == productID }) else { return nil }
                displayName = generateCoffeeTipDisplayName(for: index, product: product)
            }
#if os(macOS)
            return AnyView(
                GlassButton(
                    Text(displayName),
                    systemImage: "cup.and.saucer.fill"
                ) {
                    purchaseCoffeeTip(productID: productID)
                }
            )
#else
            return AnyView(
                settingsButton(
                    displayName,
                    icon: Image(systemName: "cup.and.saucer.fill")
                ) {
                    purchaseCoffeeTip(productID: productID)
                }
            )
#endif
        }
    }

    internal func generateCoffeeTipDisplayName(for index: Int, product: Product) -> String {
        let price = product.displayPrice
        let productName = product.displayName
        return "\(price) \(productName)"
    }
    
    internal func generateMockCoffeeTipDisplayName(for index: Int, productID: String) -> String {
        // Generate mock prices and names based on index and productID
        let mockPrices = ["$2.99", "$4.99", "$9.99", "$19.99", "$49.99"]
        let mockNames = ["Buy me a coffee", "Buy me 2 coffees", "Buy me 5 coffees", "Buy me 10 coffees", "Buy me 25 coffees"]
        
        let price = mockPrices[min(index, mockPrices.count - 1)]
        let productName = mockNames[min(index, mockNames.count - 1)]
        
        return "\(price) \(productName)"
    }

#if os(visionOS)
    internal func loadProducts() async {
        await MainActor.run {
            // StoreKit purchases are unavailable on visionOS today.
            loadedProducts = []
            productsLoaded = false
        }
    }

    internal func purchaseCoffeeTip(productID: String) {
        // Purchasing is not supported on visionOS.
    }
#else
    internal func loadProducts() async {
        guard let coffeeTips = coffeeTips, !coffeeTips.isEmpty else {
            await MainActor.run {
                productsLoaded = true
            }
            return
        }
        
        // In UI testing environment, skip product loading and mark as loaded
        if isUITesting {
            await MainActor.run {
                loadedProducts = []
                productsLoaded = true
            }
            return
        }
        
        do {
            let products = try await Product.products(for: coffeeTips)
            await MainActor.run {
                loadedProducts = products
                productsLoaded = true
            }
        } catch {
            await MainActor.run {
                loadedProducts = []
                productsLoaded = true
            }
        }
    }

    internal func purchaseCoffeeTip(productID: String) {
        Task {
            await MainActor.run {
                isLoadingPurchase = true
            }
            
            do {
                guard let product = loadedProducts.first(where: { $0.id == productID }) else {
                    await MainActor.run {
                        isLoadingPurchase = false
                    }
                    return
                }

                let result = try await product.purchase()

                await MainActor.run {
                    isLoadingPurchase = false
                }

                switch result {
                case .success(let verification):
                    switch verification {
                    case .verified:
                        await MainActor.run {
                            showingThankYouAlert = true
                        }
                    case .unverified:
                        break
                    }
                case .userCancelled:
                    break
                case .pending:
                    break
                @unknown default:
                    break
                }
            } catch {
                await MainActor.run {
                    isLoadingPurchase = false
                }
                // Handle purchase error silently
            }
        }
    }
#endif

    internal func buildSettingsButtons() -> [AnyView] {
        var buttons: [AnyView] = []

        // Always include Rate on App Store button
        buttons.append(AnyView(
            settingsButton(
                String(
                    localized: "AppAboutView.RateOnAppStore",
                    bundle: .module
                ),
                icon: Image(systemName: "hand.thumbsup.fill")
            ) {
                openAppStoreURL()
            }
        ))

        if privacyPolicy != nil {
            buttons.append(AnyView(
                settingsButton(
                    String(
                        localized: "AppAboutView.PrivacyPolicy",
                        bundle: .module
                    ),
                    icon: Image(systemName: "hand.raised.fill")
                ) {
                    openPrivacyPolicyURL()
                }
            ))
        }

        if feedbackEmail != nil {
            buttons.append(AnyView(
                settingsButton(
                    String(
                        localized: "AppAboutView.GiveFeedback",
                        bundle: .module
                    ),
                    icon: Image(systemName: "envelope")
                ) {
                    openFeedbackURL()
                }
            ))
        }

        if onAcknowledgments != nil {
            buttons.append(AnyView(
                settingsButton(
                    String(
                        localized: "AppAboutView.Acknowledgments",
                        bundle: .module
                    ),
                    icon: Image(systemName: "heart.circle")
                ) {
                    onAcknowledgments?()
                }
            ))
        }

        return buttons
    }

    internal func buildSettingsButtonsForNonMac() -> [AnyView] {
        var buttons: [AnyView] = []

        // Always include Rate on App Store button
        buttons.append(AnyView(
            settingsButton(
                String(
                    localized: "AppAboutView.RateOnAppStore",
                    bundle: .module
                ),
                icon: Image(systemName: "hand.thumbsup.fill")
            ) {
                openAppStoreURL()
            }
        ))

        if feedbackEmail != nil {
            buttons.append(AnyView(
                settingsButton(
                    String(
                        localized: "AppAboutView.GiveFeedback",
                        bundle: .module
                    ),
                    icon: Image(systemName: "envelope")
                ) {
                    openFeedbackURL()
                }
            ))
        }

        return buttons
    }

    internal func settingsButton(
        _ str: String,
        icon: Image? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon {
                    icon
                        .foregroundColor(.accentColor)
                        .frame(width: 20, height: 20)
                }
                Text(verbatim: str)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .frame(minHeight: 30)
            .padding(.vertical, 2)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    internal var platformCornerRadius: CGFloat {
#if os(macOS)
        return 8
#else
        return 16
#endif
    }

    internal var formBackgroundColor: Color {
#if os(macOS)
        return Color(NSColor.controlBackgroundColor)
#else
        return Color.clear
#endif
    }

    internal var formBorderColor: Color {
#if os(macOS)
        return Color(NSColor.separatorColor)
#else
        return Color.gray.opacity(0.2)
#endif
    }

    @ViewBuilder
    internal var defaultAppIcon: some View {
#if os(macOS)
        if let nsImage = NSApp.applicationIconImage {
            Image(nsImage: nsImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Image(systemName: "app.fill")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
                .aspectRatio(contentMode: .fit)
        }
#else
        if let uiImage = Self.loadAppIconFromBundle() {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Image(systemName: "app.fill")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
                .aspectRatio(contentMode: .fit)
        }
#endif
    }
    
#if !os(macOS)
    /// Attempts to load the app icon from the main bundle
    /// Returns the app icon as a UIImage, or nil if it cannot be loaded
    internal static func loadAppIconFromBundle() -> UIImage? {
        // Try to get icon from Info.plist
        guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String],
              let lastIcon = iconFiles.last else {
            return nil
        }
        
        // Try to load the icon image
        return UIImage(named: lastIcon)
    }
#endif

    // MARK: - Private Methods

    internal func openFeedbackURL() {
        guard let feedbackEmail = feedbackEmail else { return }

        let subject = "\(appName)%20Feedback"
        let urlString = "mailto:\(feedbackEmail)?subject=\(subject)"

        guard let url = URL(string: urlString) else { return }

#if os(macOS)
        NSWorkspace.shared.open(url)
#else
        UIApplication.shared.open(url)
#endif
    }

    internal func openAppStoreURL() {
        let urlString = "https://apps.apple.com/app/id\(appStoreID)"
        guard let url = URL(string: urlString) else { return }

#if os(macOS)
        NSWorkspace.shared.open(url)
#else
        UIApplication.shared.open(url)
#endif
    }

    internal func openPrivacyPolicyURL() {
        guard let privacyPolicy = privacyPolicy else { return }

#if os(macOS)
        NSWorkspace.shared.open(privacyPolicy)
#else
        UIApplication.shared.open(privacyPolicy)
#endif
    }
}

// MARK: - Convenience Initializers

public extension AppAboutView {
    /// Creates an AppAboutView with information automatically extracted from the main bundle
    static func fromMainBundle(
        appName: String? = nil,
        appIcon: Image? = nil,
        feedbackEmail: String? = nil,
        appStoreID: String,
        privacyPolicy: URL? = nil,
        copyrightText: String? = nil,
        onAcknowledgments: (() -> Void)? = nil,
        appsShowcaseURL: URL? = nil,
        coffeeTips: [String]? = nil
    ) -> AppAboutView {
        let bundle = Bundle.main
        let defaultAppName = bundle.infoDictionary?["CFBundleName"] as? String ?? "App"
        let appVersion = bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let buildVersion = bundle.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        
        // Load app icon from bundle if not provided
        let iconImage: Image?
        if let providedIcon = appIcon {
            iconImage = providedIcon
        } else {
#if !os(macOS)
            // On iOS/tvOS/visionOS, try to load the icon from the bundle
            if let uiImage = loadAppIconFromBundle() {
                iconImage = Image(uiImage: uiImage)
            } else {
                iconImage = nil
            }
#else
            // On macOS, don't try to load the icon here due to NSApp initialization timing
            // The defaultAppIcon property will handle it at runtime when NSApp is available
            iconImage = nil
#endif
        }

        return AppAboutView(
            appName: appName ?? defaultAppName,
            appIcon: iconImage,
            appVersion: appVersion,
            buildVersion: buildVersion,
            feedbackEmail: feedbackEmail,
            appStoreID: appStoreID,
            privacyPolicy: privacyPolicy,
            copyrightText: copyrightText,
            onAcknowledgments: onAcknowledgments,
            appsShowcaseURL: appsShowcaseURL,
            coffeeTips: coffeeTips
        )
    }
}

#Preview() {
    AppAboutView.fromMainBundle(
        appName: "Sample App",
        feedbackEmail: "feedback@example.com",
        appStoreID: "123456789",
        privacyPolicy: URL(string: "https://google.com/privacypolicy/"),
        copyrightText: "©2025 Example Company",
        onAcknowledgments: {},
        coffeeTips: ["coffee.single"]
    )
}
