import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

#if !os(macOS)
extension AppAboutView {
    @ViewBuilder
    func buildNormalLayout() -> some View {
        ScrollView(.vertical) {
            VStack(spacing: 20) {
                // App Icon and Version
                VStack(spacing: 12) {
                    if let appIcon = appIcon {
                        appIcon
                            .resizable()
                            .frame(width: 96, height: 96)
                            .clipShape(RoundedRectangle(cornerRadius: platformCornerRadius))
                    } else {
                        defaultAppIcon
                            .frame(width: 96, height: 96)
                    }

                    Text(appName)
                        .font(.largeTitle)
                        .fontWeight(.medium)

                    Text(String(format: String(localized: "AppAboutView.Version", bundle: .module), appVersion, buildVersion))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)

                // Actions Form
                VStack(spacing: 0) {
                    let buttons = buildSettingsButtons()
                    ForEach(Array(buttons.enumerated()), id: \.offset) { index, button in
                        button

                        if index < buttons.count - 1 {
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
                .padding(.vertical, 16)
                .background(formBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(formBorderColor, lineWidth: 1)
                )

                // Coffee Tips Section
                if let coffeeTips = coffeeTips, !coffeeTips.isEmpty, !loadedProducts.isEmpty, !isLoadingPurchase {
                    buildCoffeeTipsSection()
                        .transition(.opacity)
                        .animation(.easeIn(duration: 0.3), value: productsLoaded)
                }

                // App Showcase Section
                if appsShowcaseURL != nil {
                    Text(String(localized: "AppAboutView.MyApps", bundle: .module))
                        .font(.headline)
                        .fontWeight(.medium)

                    AppShowcaseView(remoteURL: appsShowcaseURL, currentAppStoreID: appStoreID)
                        .background(formBackgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(formBorderColor, lineWidth: 1)
                        )
                }

                // Copyright
                if let copyrightText = copyrightText {
                    Text(copyrightText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 30)
        }
        .navigationTitle(
            String(localized: "AppAboutView.About", bundle: .module)
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert(
            String(localized: "AppAboutView.ThankYou", bundle: .module),
            isPresented: $showingThankYouAlert
        ) {
            Button(String(localized: "AppAboutView.OK", bundle: .module)) { }
        } message: {
            Text(String(localized: "AppAboutView.ThankYouMessage", bundle: .module))
        }
    }
}
#endif
