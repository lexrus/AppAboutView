import SwiftUI

import AppAboutView

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // The full AppAboutView, wired with the real remote apps.json
                    // so the 7-icon showcase is what we're verifying.
                    AppAboutView(
                        appName: "AppAboutView Demo",
                        appIcon: Image(systemName: "sparkles"),
                        appVersion: "1.0.0",
                        buildVersion: "1",
                        feedbackEmail: "lex@example.com",
                        appStoreID: "6748440814",
                        privacyPolicy: URL(string: "https://lex.sh/privacy"),
                        copyrightText: "©2025 Lex",
                        appsShowcaseURL: URL(string: "https://lex.sh/apps/apps.json"),
                        coffeeTips: ["tip.small", "tip.large"]
                    )
                }
                .padding()
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}
