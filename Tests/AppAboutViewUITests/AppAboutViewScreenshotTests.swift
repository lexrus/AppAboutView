import Testing
import SwiftUI
@testable import AppAboutView

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

@MainActor
struct AppAboutViewScreenshotTests {
    
    // MARK: - Basic Configuration Tests
    
    @Test("AppAboutView - Minimal Configuration")
    func testAppAboutViewMinimalConfiguration() async throws {
        let view = AppAboutView(
            appName: "Minimal App",
            appStoreID: "123456789"
        )
        
        // Test both light and dark modes
        await testBothColorSchemes(view: view, baseName: "AppAboutView_Minimal")
    }
    
    @Test("AppAboutView - Full Configuration")
    func testAppAboutViewFullConfiguration() async throws {
        let view = AppAboutView(
            appName: "Amazing App",
            appIcon: Image(systemName: "star.fill"),
            appVersion: "2.1.0",
            buildVersion: "2024.12.01",
            feedbackEmail: "support@amazingapp.com",
            appStoreID: "987654321",
            privacyPolicy: URL(string: "https://amazingapp.com/privacy"),
            copyrightText: "©2025 Amazing App Inc. All rights reserved.",
            onAcknowledgments: { print("Acknowledgments") },
            appsShowcaseURL: URL(string: "https://raw.githubusercontent.com/example/apps.json"),
            coffeeTips: ["coffee.single", "coffee.double", "coffee.triple"]
        )
        
        // Test both light and dark modes
        await testBothColorSchemes(view: view, baseName: "AppAboutView_Full", waitTime: 2_000_000_000)
    }
    
    @Test("AppAboutView - Coffee Tips Only")
    func testAppAboutViewCoffeeTipsOnly() async throws {
        let view = AppAboutView(
            appName: "Coffee Support App",
            appIcon: Image(systemName: "cup.and.saucer.fill"),
            appStoreID: "111111111",
            coffeeTips: ["tip.small", "tip.medium", "tip.large", "tip.extra"]
        )
        
        await testBothColorSchemes(view: view, baseName: "AppAboutView_CoffeeTips")
    }
    
    @Test("AppAboutView - Privacy Policy Only")
    func testAppAboutViewPrivacyPolicyOnly() async throws {
        let view = AppAboutView(
            appName: "Privacy First App",
            appIcon: Image(systemName: "shield.fill"),
            appStoreID: "222222222",
            privacyPolicy: URL(string: "https://privacyfirst.com/policy"),
            copyrightText: "©2025 Privacy First Inc."
        )
        
        await testBothColorSchemes(view: view, baseName: "AppAboutView_PrivacyOnly")
    }
    
    @Test("AppAboutView - Feedback Email Only")
    func testAppAboutViewFeedbackEmailOnly() async throws {
        let view = AppAboutView(
            appName: "Feedback Friendly",
            appIcon: Image(systemName: "envelope.fill"),
            feedbackEmail: "hello@feedbackfriendly.com",
            appStoreID: "333333333"
        )
        
        await testBothColorSchemes(view: view, baseName: "AppAboutView_FeedbackOnly")
    }
    
    @Test("AppAboutView - Acknowledgments Only")
    func testAppAboutViewAcknowledgmentsOnly() async throws {
        let view = AppAboutView(
            appName: "Open Source App",
            appIcon: Image(systemName: "heart.circle.fill"),
            appStoreID: "444444444",
            onAcknowledgments: { print("Show acknowledgments") }
        )
        
        await testBothColorSchemes(view: view, baseName: "AppAboutView_AcknowledgmentsOnly")
    }
    
    // MARK: - Special Character and Long Text Tests
    
    @Test("AppAboutView - Special Characters")
    func testAppAboutViewSpecialCharacters() async throws {
        let view = AppAboutView(
            appName: "Spëcîàł Çhärãctęrs App™",
            appIcon: Image(systemName: "textformat"),
            appVersion: "1.0.0-beta.1",
            buildVersion: "build#123",
            feedbackEmail: "tëst@éxãmplé.com",
            appStoreID: "555555555",
            copyrightText: "©2025 Spëcîàł Çömpäny™ • All rights reserved"
        )
        
        await testBothColorSchemes(view: view, baseName: "AppAboutView_SpecialCharacters")
    }
    
    @Test("AppAboutView - Long App Name")
    func testAppAboutViewLongAppName() async throws {
        let view = AppAboutView(
            appName: "This is a Very Long Application Name That Should Test Text Wrapping",
            appIcon: Image(systemName: "text.alignleft"),
            appStoreID: "666666666"
        )
        
        await testBothColorSchemes(view: view, baseName: "AppAboutView_LongName")
    }
    
    // MARK: - Different Screen Sizes
    
    @Test("AppAboutView - Different Screen Sizes")
    func testAppAboutViewDifferentSizes() async throws {
        let view = AppAboutView(
            appName: "Size Test App",
            appIcon: Image(systemName: "rectangle.3.group.fill"),
            appVersion: "1.0.0",
            buildVersion: "1",
            feedbackEmail: "test@sizetest.com",
            appStoreID: "777777777",
            privacyPolicy: URL(string: "https://sizetest.com/privacy"),
            coffeeTips: ["tip.small", "tip.large"]
        )
        
        let sizes = [
            ("Compact", CGSize(width: 320, height: 568)),  // iPhone SE size
            ("Regular", CGSize(width: 375, height: 667)),  // iPhone 8 size
            ("Large", CGSize(width: 414, height: 896)),    // iPhone 11 Pro Max size
            ("iPad", CGSize(width: 768, height: 1024)),    // iPad size
            ("Wide", CGSize(width: 600, height: 400))      // Wide aspect ratio
        ]
        
        for (sizeName, size) in sizes {
            await testBothColorSchemes(view: view, baseName: "AppAboutView_Size_\(sizeName)_\(Int(size.width))x\(Int(size.height))", size: size, waitTime: 1_500_000_000)
        }
    }
    
    // MARK: - Platform-Specific Tests
    
    #if os(macOS)
    @Test("AppAboutView - macOS Specific Styling")
    func testAppAboutViewMacOSSpecific() async throws {
        let view = AppAboutView(
            appName: "macOS Native App",
            appIcon: Image(systemName: "laptopcomputer"),
            appVersion: "3.2.1",
            buildVersion: "2024.08.04",
            feedbackEmail: "mac@nativeapp.com",
            appStoreID: "888888888",
            privacyPolicy: URL(string: "https://nativeapp.com/privacy"),
            copyrightText: "©2025 Native App Corp.",
            coffeeTips: ["mac.coffee.single", "mac.coffee.double"]
        )
        
        await testBothColorSchemes(view: view, baseName: "AppAboutView_macOS", size: CGSize(width: 600, height: 800), waitTime: 1_500_000_000)
    }
    #endif
    
    #if os(iOS)
    @Test("AppAboutView - iOS Specific Styling")
    func testAppAboutViewiOSSpecific() async throws {
        let view = AppAboutView(
            appName: "iOS Native App",
            appIcon: Image(systemName: "iphone"),
            appVersion: "4.1.2",
            buildVersion: "2024.08.04",
            feedbackEmail: "ios@nativeapp.com",
            appStoreID: "999999999",
            privacyPolicy: URL(string: "https://nativeapp.com/privacy"),
            copyrightText: "©2025 Native App Corp.",
            coffeeTips: ["ios.coffee.single", "ios.coffee.double"]
        )
        
        await testBothColorSchemes(view: view, baseName: "AppAboutView_iOS", size: CGSize(width: 375, height: 667), waitTime: 1_500_000_000)
    }
    #endif
    
    // MARK: - Edge Cases
    
    @Test("AppAboutView - Empty Coffee Tips Array")
    func testAppAboutViewEmptyCoffeeTips() async throws {
        let view = AppAboutView(
            appName: "No Tips App",
            appStoreID: "101010101",
            coffeeTips: []  // Empty array should not show coffee section
        )
        
        await testBothColorSchemes(view: view, baseName: "AppAboutView_EmptyCoffeeTips")
    }
    
    @Test("AppAboutView - Single Coffee Tip")
    func testAppAboutViewSingleCoffeeTip() async throws {
        let view = AppAboutView(
            appName: "Single Tip App",
            appIcon: Image(systemName: "cup.and.saucer"),
            appStoreID: "202020202",
            coffeeTips: ["single.tip"]
        )
        
        await testBothColorSchemes(view: view, baseName: "AppAboutView_SingleCoffeeTip")
    }
    
    // MARK: - Helper Methods
    
    /// Test a view in both light and dark color schemes
    private func testBothColorSchemes<Content: View>(
        view: Content, 
        baseName: String, 
        size: CGSize = CGSize(width: 375, height: 667),
        waitTime: UInt64 = 1_000_000_000
    ) async {
        // Test light mode
        let lightController = createHostingController(for: view, size: size, colorScheme: .light)
        try? await Task.sleep(nanoseconds: waitTime)
        takeScreenshot(of: lightController, named: "\(baseName)_Light")
        
        // Test dark mode
        let darkController = createHostingController(for: view, size: size, colorScheme: .dark)
        try? await Task.sleep(nanoseconds: waitTime)
        takeScreenshot(of: darkController, named: "\(baseName)_Dark")
    }
    
    #if canImport(UIKit)
    private func createHostingController<Content: View>(
        for view: Content, 
        size: CGSize = CGSize(width: 375, height: 667),
        colorScheme: ColorScheme = .light
    ) -> UIHostingController<some View> {
        let backgroundView = ZStack {
            // Add solid background based on color scheme
            (colorScheme == .dark ? Color.black : Color.white)
                .ignoresSafeArea()
            
            ScrollView(.vertical) {
                view
            }
        }
        .environment(\.colorScheme, colorScheme)
        .preferredColorScheme(colorScheme)
        
        let hostingController = UIHostingController(rootView: backgroundView)
        hostingController.view.frame = CGRect(origin: .zero, size: size)
        
        // Set background color based on color scheme
        hostingController.view.backgroundColor = colorScheme == .dark ? UIColor.black : UIColor.white
        
        // Add to a window for proper rendering
        let window = UIWindow(frame: CGRect(origin: .zero, size: size))
        window.backgroundColor = colorScheme == .dark ? UIColor.black : UIColor.white
        window.rootViewController = hostingController
        window.makeKeyAndVisible()
        
        return hostingController
    }
    
    private func takeScreenshot(of hostingController: UIHostingController<some View>, named name: String) {
        guard let view = hostingController.view else {
            print("❌ No view available for screenshot")
            return
        }
        
        // Force layout
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        let image = renderer.image { context in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        
        saveScreenshot(image: image, named: name)
    }
    
    private func saveScreenshot(image: UIImage, named name: String) {
        guard let data = image.pngData() else {
            print("❌ Failed to convert image to PNG data")
            return
        }
        
        let screenshotsDir = getScreenshotsDirectory()
        let filename = "\(name).png"
        let fileURL = screenshotsDir.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            print("📸 Screenshot saved: \(fileURL.path)")
        } catch {
            print("❌ Failed to save screenshot: \(error)")
        }
    }
    #endif
    
    #if canImport(AppKit)
    private func createHostingController<Content: View>(
        for view: Content, 
        size: CGSize = CGSize(width: 600, height: 800),
        colorScheme: ColorScheme = .light
    ) -> NSHostingController<some View> {
        let backgroundView = ZStack {
            // Add solid background based on color scheme
            (colorScheme == .dark ? Color.black : Color.white)
                .ignoresSafeArea()
            
            ScrollView(.vertical) {
                view
            }
        }
        .environment(\.colorScheme, colorScheme)
        .preferredColorScheme(colorScheme)
        
        let hostingController = NSHostingController(rootView: backgroundView)
        hostingController.view.frame = CGRect(origin: .zero, size: size)
        
        // Create a window for proper rendering
        let window = NSWindow(
            contentRect: CGRect(origin: .zero, size: size),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.contentViewController = hostingController
        window.backgroundColor = colorScheme == .dark ? NSColor.black : NSColor.white
        window.makeKeyAndOrderFront(nil)
        
        return hostingController
    }
    
    private func takeScreenshot(of hostingController: NSHostingController<some View>, named name: String) {
        let view = hostingController.view
        
        // Force layout
        view.needsLayout = true
        view.layout()
        
        let bounds = view.bounds
        guard let bitmapRep = view.bitmapImageRepForCachingDisplay(in: bounds) else {
            print("❌ Failed to create bitmap representation")
            return
        }
        
        view.cacheDisplay(in: bounds, to: bitmapRep)
        
        let image = NSImage(size: bounds.size)
        image.addRepresentation(bitmapRep)
        
        saveScreenshot(image: image, named: name)
    }
    
    private func saveScreenshot(image: NSImage, named name: String) {  
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            print("❌ Failed to convert NSImage to CGImage")
            return
        }
        
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        guard let data = bitmapRep.representation(using: .png, properties: [:]) else {
            print("❌ Failed to convert image to PNG data")
            return
        }
        
        let screenshotsDir = getScreenshotsDirectory()
        let filename = "\(name).png"
        let fileURL = screenshotsDir.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            print("📸 Screenshot saved: \(fileURL.path)")
        } catch {
            print("❌ Failed to save screenshot: \(error)")
        }
    }
    #endif
    
    private func getScreenshotsDirectory() -> URL {
        let currentFile = URL(fileURLWithPath: #file)
        
        let projectRoot = currentFile
            .deletingLastPathComponent()  // Remove AppAboutViewScreenshotTests.swift
            .deletingLastPathComponent()  // Remove AppAboutViewUITests/
            .deletingLastPathComponent()  // Remove Tests/
        
        let screenshotsDir = projectRoot.appendingPathComponent("screenshots")
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: screenshotsDir, withIntermediateDirectories: true, attributes: nil)
        
        return screenshotsDir
    }
}