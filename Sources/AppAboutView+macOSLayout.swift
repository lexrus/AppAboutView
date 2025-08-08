import SwiftUI

#if canImport(AppKit)
import AppKit
#endif

#if os(macOS)
extension AppAboutView {
    @ViewBuilder
    func buildMacOSLayout() -> some View {
        HStack(alignment: .top, spacing: 0) {
            // Left Column - Static (non-scrollable)
            VStack(spacing: 20) {
                // App Icon and Info
                VStack(spacing: 12) {
                    if let appIcon = appIcon {
                        appIcon
                            .resizable()
                            .frame(width: 128, height: 128)
                            .clipShape(RoundedRectangle(cornerRadius: platformCornerRadius))
                    } else {
                        defaultAppIcon
                            .frame(width: 128, height: 128)
                    }

                    Text(appName)
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)

                    Text(String(format: String(localized: "AppAboutView.Version", bundle: .module), appVersion, buildVersion))
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    // Privacy Policy and Acknowledgments buttons
                    VStack(spacing: 8) {
                        if privacyPolicy != nil {
                            Button(String(localized: "AppAboutView.PrivacyPolicy", bundle: .module)) {
                                openPrivacyPolicyURL()
                            }
                            .buttonStyle(.plain)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .underline()
                        }

                        if onAcknowledgments != nil {
                            Button(String(localized: "AppAboutView.Acknowledgments", bundle: .module)) {
                                onAcknowledgments?()
                            }
                            .buttonStyle(.plain)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .underline()
                        }
                    }
                    .padding(.top, 4)
                }

                Spacer()

                // Bottom section with copyright
                if let copyrightText = copyrightText {
                    Text(copyrightText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(minWidth: 150)
            .padding(.leading, 30)
            .padding(.vertical, 30)

            // Right Column - Scrollable
            ScrollView(.vertical) {
                VStack(spacing: 16) {
                    // Action buttons using GlassButton
                    HStack(spacing: 16) {
                        GlassButton(
                            Text(String(localized: "AppAboutView.RateOnAppStore", bundle: .module)),
                            systemImage: "hand.thumbsup.fill"
                        ) {
                            openAppStoreURL()
                        }

                        if feedbackEmail != nil {
                            GlassButton(
                                Text(String(localized: "AppAboutView.GiveFeedback", bundle: .module)),
                                systemImage: "envelope"
                            ) {
                                openFeedbackURL()
                            }
                        }
                    }

                    // Coffee Tips Section
                    if let coffeeTips = coffeeTips, !coffeeTips.isEmpty, !loadedProducts.isEmpty, !isLoadingPurchase {
                        buildCoffeeTipsSection()
                    }

                    // App Showcase Section
                    AppShowcaseView(remoteURL: appsShowcaseURL, currentAppStoreID: appStoreID)
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 30)
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(
            String(localized: "AppAboutView.About", bundle: .module)
        )
        .frame(minWidth: 500, maxWidth: .infinity, maxHeight: .infinity)
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
