import Testing
import SwiftUI
@testable import AppAboutView

#if canImport(AppKit)
import AppKit

@MainActor
struct AppAboutViewScreenshotTests_macOS {
    
    // MARK: - macOS Platform-Specific Tests
    
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
    
    @Test("AppAboutView - macOS Different Window Sizes")
    func testAppAboutViewMacOSDifferentSizes() async throws {
        let view = AppAboutView(
            appName: "macOS Size Test",
            appIcon: Image(systemName: "macwindow"),
            appVersion: "1.0.0",
            buildVersion: "1",
            feedbackEmail: "test@macostest.com",
            appStoreID: "777777777",
            privacyPolicy: URL(string: "https://macostest.com/privacy"),
            coffeeTips: ["tip.small", "tip.large"]
        )
        
        let macOSSizes = [
            ("Compact", CGSize(width: 500, height: 400)),   // Small macOS window
            ("Standard", CGSize(width: 600, height: 600)),  // Standard macOS window
            ("Wide", CGSize(width: 800, height: 400))       // Wide macOS window
        ]
        
        for (sizeName, size) in macOSSizes {
            await testBothColorSchemes(
                view: view,
                baseName: "AppAboutView_macOS_Size_\(sizeName)_\(Int(size.width))x\(Int(size.height))",
                size: size,
                waitTime: 1_500_000_000
            )
        }
    }
    
    // MARK: - Helper Methods
    
    /// Test a view in both light and dark color schemes
    private func testBothColorSchemes<Content: View>(
        view: Content, 
        baseName: String, 
        size: CGSize = CGSize(width: 600, height: 800),
        waitTime: UInt64 = 1_000_000_000
    ) async {
        // Test light mode
        let (lightController, lightWindow) = createHostingController(for: view, size: size, colorScheme: .light)
        try? await Task.sleep(nanoseconds: waitTime)
        takeScreenshot(of: lightController, window: lightWindow, named: "\(baseName)_Light")
        
        // Test dark mode
        let (darkController, darkWindow) = createHostingController(for: view, size: size, colorScheme: .dark)
        try? await Task.sleep(nanoseconds: waitTime)
        takeScreenshot(of: darkController, window: darkWindow, named: "\(baseName)_Dark")
    }
    
    private func createHostingController<Content: View>(
        for view: Content, 
        size: CGSize = CGSize(width: 600, height: 800),
        colorScheme: ColorScheme = .light
    ) -> (NSHostingController<some View>, NSWindow) {
        let backgroundView = ZStack {
            // Add solid background based on color scheme
            (colorScheme == .dark ? Color(white: 0.1) : Color(white: 0.9))
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
        window.backgroundColor = colorScheme == .dark ? NSColor(white: 0.1, alpha: 1) : NSColor(white: 0.9, alpha: 1)
        window.title = "AppAboutView Demo"
        window.makeKeyAndOrderFront(nil)
        
        return (hostingController, window)
    }
    
    private func takeScreenshot(of hostingController: NSHostingController<some View>, window: NSWindow, named name: String) {
        // Force layout and ensure window is visible
        hostingController.view.needsLayout = true
        hostingController.view.layout()
        
        // Give the window time to render
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        
        // Get the actual rendered size including title bar
        let windowFrame = window.frame
        let contentFrame = window.contentView?.frame ?? CGRect.zero
        let titleBarHeight = windowFrame.height - contentFrame.height
        
        // Create bitmap representation of the content view first
        guard let contentView = window.contentView else {
            print("❌ No content view available")
            return
        }
        
        let contentBounds = contentView.bounds
        guard let contentBitmapRep = contentView.bitmapImageRepForCachingDisplay(in: contentBounds) else {
            print("❌ Failed to create content bitmap representation")
            return
        }
        
        contentView.cacheDisplay(in: contentBounds, to: contentBitmapRep)
        
        // Create the final image with window frame + content
        let finalSize = CGSize(width: windowFrame.width, height: windowFrame.height)
        let finalImage = NSImage(size: finalSize)
        
        finalImage.lockFocus()
        
        // Draw the title bar background
        let isDark = hostingController.view.effectiveAppearance.name == .darkAqua
        let titleBarColor = isDark ? NSColor(white: 0.2, alpha: 1.0) : NSColor(white: 0.95, alpha: 1.0)
        titleBarColor.setFill()
        NSRect(x: 0, y: finalSize.height - titleBarHeight, width: finalSize.width, height: titleBarHeight).fill()
        
        // Draw window title
        let title = window.title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 13),
            .foregroundColor: isDark ? NSColor.white : NSColor.black
        ]
        let titleSize = title.size(withAttributes: titleAttributes)
        let titleX = (finalSize.width - titleSize.width) / 2
        let titleY = finalSize.height - titleBarHeight + (titleBarHeight - titleSize.height) / 2
        title.draw(at: NSPoint(x: titleX, y: titleY), withAttributes: titleAttributes)
        
        // Draw the content view bitmap
        let contentImage = NSImage()
        contentImage.addRepresentation(contentBitmapRep)
        let contentRect = NSRect(x: 0, y: 0, width: finalSize.width, height: finalSize.height - titleBarHeight)
        contentImage.draw(in: contentRect)
        
        finalImage.unlockFocus()
        
        saveScreenshot(image: finalImage, named: name)
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
    
    private func getScreenshotsDirectory() -> URL {
        // Use more robust path resolution by looking for Package.swift
        let currentFile = URL(fileURLWithPath: #file)
        var searchDir = currentFile.deletingLastPathComponent()
        
        // Walk up the directory tree until we find Package.swift (project root)
        while searchDir.path != "/" {
            let packageSwiftPath = searchDir.appendingPathComponent("Package.swift")
            
            if FileManager.default.fileExists(atPath: packageSwiftPath.path) {
                // Found project root, create screenshots directory here
                let screenshotsDir = searchDir.appendingPathComponent("screenshots")
                
                // Create directory if it doesn't exist
                try? FileManager.default.createDirectory(at: screenshotsDir, withIntermediateDirectories: true, attributes: nil)
                
                return screenshotsDir
            }
            searchDir = searchDir.deletingLastPathComponent()
        }
        
        // Fallback: use the original approach if Package.swift not found
        let projectRoot = currentFile
            .deletingLastPathComponent()  // Remove AppAboutViewScreenshotTests_macOS.swift
            .deletingLastPathComponent()  // Remove AppAboutViewUITests/
            .deletingLastPathComponent()  // Remove Tests/
        
        let screenshotsDir = projectRoot.appendingPathComponent("screenshots")
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: screenshotsDir, withIntermediateDirectories: true, attributes: nil)
        
        return screenshotsDir
    }
}

#endif
