import Testing
import Foundation
@testable import AppAboutView

// MARK: - Platform Enum Tests

@Test func testPlatformAllCases() {
    let allPlatforms = Platform.allCases
    
    #expect(allPlatforms.count == 6)
    #expect(allPlatforms.contains(.macOS))
    #expect(allPlatforms.contains(.iOS))
    #expect(allPlatforms.contains(.iPadOS))
    #expect(allPlatforms.contains(.watchOS))
    #expect(allPlatforms.contains(.tvOS))
    #expect(allPlatforms.contains(.visionOS))
}

@Test func testPlatformDisplayNames() {
    #expect(Platform.macOS.displayName == "macOS")
    #expect(Platform.iOS.displayName == "iOS")
    #expect(Platform.iPadOS.displayName == "iPadOS")
    #expect(Platform.watchOS.displayName == "watchOS")
    #expect(Platform.tvOS.displayName == "tvOS")
    #expect(Platform.visionOS.displayName == "visionOS")
}

@Test func testPlatformSystemImageNames() {
    #expect(Platform.macOS.systemImageName == "desktopcomputer")
    #expect(Platform.iOS.systemImageName == "iphone")
    #expect(Platform.iPadOS.systemImageName == "ipad")
    #expect(Platform.watchOS.systemImageName == "applewatch")
    #expect(Platform.tvOS.systemImageName == "appletv")
    #expect(Platform.visionOS.systemImageName == "visionpro")
}

@Test func testPlatformRawValues() {
    #expect(Platform.macOS.rawValue == "macOS")
    #expect(Platform.iOS.rawValue == "iOS")
    #expect(Platform.iPadOS.rawValue == "iPadOS")
    #expect(Platform.watchOS.rawValue == "watchOS")
    #expect(Platform.tvOS.rawValue == "tvOS")
    #expect(Platform.visionOS.rawValue == "visionOS")
}

@Test func testPlatformInitFromRawValue() {
    #expect(Platform(rawValue: "macOS") == .macOS)
    #expect(Platform(rawValue: "iOS") == .iOS)
    #expect(Platform(rawValue: "iPadOS") == .iPadOS)
    #expect(Platform(rawValue: "watchOS") == .watchOS)
    #expect(Platform(rawValue: "tvOS") == .tvOS)
    #expect(Platform(rawValue: "visionOS") == .visionOS)
    
    // Test invalid raw values
    #expect(Platform(rawValue: "invalidOS") == nil)
    #expect(Platform(rawValue: "macos") == nil) // Case sensitive
    #expect(Platform(rawValue: "MACOS") == nil) // Case sensitive
    #expect(Platform(rawValue: "") == nil)
}

// MARK: - Platform Codable Tests

@Test func testPlatformCodable() throws {
    let platforms: [Platform] = [.iOS, .macOS, .visionOS]
    
    // Encode to JSON
    let encoder = JSONEncoder()
    let data = try encoder.encode(platforms)
    
    // Verify JSON structure
    let jsonArray = try JSONSerialization.jsonObject(with: data) as? [String]
    #expect(jsonArray?.count == 3)
    #expect(jsonArray?.contains("iOS") == true)
    #expect(jsonArray?.contains("macOS") == true)
    #expect(jsonArray?.contains("visionOS") == true)
    
    // Decode back
    let decoder = JSONDecoder()
    let decoded = try decoder.decode([Platform].self, from: data)
    
    #expect(decoded == platforms)
    #expect(decoded.count == 3)
    #expect(decoded.contains(.iOS))
    #expect(decoded.contains(.macOS))
    #expect(decoded.contains(.visionOS))
}

@Test func testPlatformSingleCodable() throws {
    for platform in Platform.allCases {
        // Test encoding/decoding each platform individually
        let encoder = JSONEncoder()
        let data = try encoder.encode(platform)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Platform.self, from: data)
        
        #expect(decoded == platform)
        #expect(decoded.rawValue == platform.rawValue)
        #expect(decoded.displayName == platform.displayName)
        #expect(decoded.systemImageName == platform.systemImageName)
    }
}

@Test func testPlatformCodableWithInvalidData() {
    let invalidJSON = """
    ["iOS", "invalidPlatform", "macOS"]
    """.data(using: .utf8)!
    
    let decoder = JSONDecoder()
    
    // Should throw when encountering invalid platform
    #expect(throws: DecodingError.self) {
        _ = try decoder.decode([Platform].self, from: invalidJSON)
    }
}

@Test func testPlatformCodableEmptyArray() throws {
    let emptyPlatforms: [Platform] = []
    
    let encoder = JSONEncoder()
    let data = try encoder.encode(emptyPlatforms)
    
    let decoder = JSONDecoder()
    let decoded = try decoder.decode([Platform].self, from: data)
    
    #expect(decoded.isEmpty)
    #expect(decoded == emptyPlatforms)
}

// MARK: - Platform Comparison Tests

@Test func testPlatformEquality() {
    #expect(Platform.iOS == Platform.iOS)
    #expect(Platform.macOS == Platform.macOS)
    #expect(Platform.iOS != Platform.macOS)
    #expect(Platform.iPadOS != Platform.iOS)
    #expect(Platform.watchOS != Platform.tvOS)
}

@Test func testPlatformHashable() {
    let iosSet: Set<Platform> = [.iOS, .iOS, .iOS]
    #expect(iosSet.count == 1)
    
    let mixedSet: Set<Platform> = [.iOS, .macOS, .iPadOS, .iOS, .macOS]
    #expect(mixedSet.count == 3)
    #expect(mixedSet.contains(.iOS))
    #expect(mixedSet.contains(.macOS))
    #expect(mixedSet.contains(.iPadOS))
    
    let allPlatformsSet = Set(Platform.allCases)
    #expect(allPlatformsSet.count == Platform.allCases.count)
}

// MARK: - Platform Integration Tests

@Test func testPlatformWithMyAppInfo() {
    let platforms: [Platform] = [.iOS, .macOS]
    let appInfo = MyAppInfo(
        id: "com.test.platform",
        name: "Platform Test App",
        briefDescription: LocalizedDescription(en: "Testing platforms"),
        appStoreID: "123456789",
        platforms: platforms
    )
    
    #expect(appInfo.platforms.count == 2)
    #expect(appInfo.platforms.contains(.iOS))
    #expect(appInfo.platforms.contains(.macOS))
    #expect(!appInfo.platforms.contains(.watchOS))
}

@Test func testPlatformSystemImageConsistency() {
    // Verify that system image names are consistent and valid
    let expectedImages = [
        Platform.macOS: "desktopcomputer",
        Platform.iOS: "iphone",
        Platform.iPadOS: "ipad",
        Platform.watchOS: "applewatch",
        Platform.tvOS: "appletv",
        Platform.visionOS: "visionpro"
    ]
    
    for (platform, expectedImage) in expectedImages {
        #expect(platform.systemImageName == expectedImage)
        #expect(!platform.systemImageName.isEmpty)
    }
}

@Test func testPlatformDisplayNameConsistency() {
    // Verify display names match raw values for consistency
    for platform in Platform.allCases {
        #expect(platform.displayName == platform.rawValue)
        #expect(!platform.displayName.isEmpty)
    }
}

// MARK: - Platform Array Operations Tests

@Test func testPlatformArrayOperations() {
    let mobilePlatforms: [Platform] = [.iOS, .iPadOS, .watchOS]
    let desktopPlatforms: [Platform] = [.macOS]
    let tvPlatforms: [Platform] = [.tvOS, .visionOS]
    
    let allTestPlatforms = mobilePlatforms + desktopPlatforms + tvPlatforms
    #expect(allTestPlatforms.count == 6)
    
    // Test filtering
    let applePlatforms = allTestPlatforms.filter { platform in
        ["iOS", "iPadOS", "macOS", "watchOS", "tvOS", "visionOS"].contains(platform.rawValue)
    }
    #expect(applePlatforms.count == 6)
    
    // Test mapping
    let displayNames = allTestPlatforms.map { $0.displayName }
    #expect(displayNames.contains("iOS"))
    #expect(displayNames.contains("macOS"))
    #expect(displayNames.contains("visionOS"))
}

@Test func testPlatformSorting() {
    let unsortedPlatforms: [Platform] = [.visionOS, .iOS, .macOS, .watchOS, .tvOS, .iPadOS]
    
    // Sort by raw value
    let sortedByRawValue = unsortedPlatforms.sorted { $0.rawValue < $1.rawValue }
    #expect(sortedByRawValue.first == .iOS)
    #expect(sortedByRawValue.last == .watchOS)
    
    // Sort by display name (should be the same as raw value in this case)
    let sortedByDisplayName = unsortedPlatforms.sorted { $0.displayName < $1.displayName }
    #expect(sortedByDisplayName == sortedByRawValue)
}

// MARK: - Platform Edge Cases Tests

@Test func testPlatformMemoryFootprint() {
    // Test that Platform enum has minimal memory footprint
    let platforms = Platform.allCases
    
    // Should be able to create many instances without issues
    let manyPlatforms = Array(repeating: platforms, count: 1000).flatMap { $0 }
    #expect(manyPlatforms.count == 6000)
    
    // Test unique platforms in large array
    let uniquePlatforms = Set(manyPlatforms)
    #expect(uniquePlatforms.count == 6)
}

@Test func testPlatformStringInterpolation() {
    let platform = Platform.iOS
    let description = "This app runs on \(platform.displayName)"
    #expect(description == "This app runs on iOS")
    
    let systemImageDescription = "Icon: \(platform.systemImageName)"
    #expect(systemImageDescription == "Icon: iphone")
}