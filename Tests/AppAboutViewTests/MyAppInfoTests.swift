import Testing
import Foundation
@testable import AppAboutView

// MARK: - MyAppInfo Data Model Tests

@Test func testMyAppInfoInitialization() {
    let description = LocalizedDescription(en: "A great app")
    let platforms = [Platform.iOS, Platform.macOS]
    
    let appInfo = MyAppInfo(
        id: "com.test.app",
        name: "Test App",
        briefDescription: description,
        iconURL: "https://example.com/icon.png",
        appStoreID: "123456789",
        platforms: platforms
    )

    #expect(appInfo.id == "com.test.app")
    #expect(appInfo.name == "Test App")
    #expect(appInfo.briefDescription == description)
    #expect(appInfo.iconURL == "https://example.com/icon.png")
    #expect(appInfo.appStoreID == "123456789")
    #expect(appInfo.platforms == platforms)
}

@Test func testMyAppInfoWithoutIconURL() {
    let description = LocalizedDescription(en: "Another app")
    let platforms = [Platform.iPadOS]
    
    let appInfo = MyAppInfo(
        id: "com.test.another",
        name: "Another App",
        briefDescription: description,
        appStoreID: "987654321",
        platforms: platforms
    )

    #expect(appInfo.iconURL == nil)
    #expect(appInfo.name == "Another App")
    #expect(appInfo.platforms == [Platform.iPadOS])
}

@Test func testMyAppInfoIdentifiable() {
    let appInfo = MyAppInfo(
        id: "unique.identifier",
        name: "Test",
        briefDescription: LocalizedDescription(en: "Test"),
        appStoreID: "123",
        platforms: [.iOS]
    )
    
    #expect(appInfo.id == "unique.identifier")
    // Test that it conforms to Identifiable
    let identifiableId: String = appInfo.id
    #expect(identifiableId == "unique.identifier")
}

@Test func testMyAppInfoHashable() {
    let desc = LocalizedDescription(en: "Test app")
    let app1 = MyAppInfo(
        id: "com.test.app1",
        name: "Test App 1",
        briefDescription: desc,
        appStoreID: "111",
        platforms: [.iOS]
    )
    
    let app2 = MyAppInfo(
        id: "com.test.app1", // Same ID
        name: "Test App 1",
        briefDescription: desc,
        appStoreID: "111",
        platforms: [.iOS]
    )
    
    let app3 = MyAppInfo(
        id: "com.test.app2", // Different ID
        name: "Test App 2",
        briefDescription: desc,
        appStoreID: "222",
        platforms: [.iOS]
    )
    
    // Test hash equality
    #expect(app1.hashValue == app2.hashValue)
    #expect(app1.hashValue != app3.hashValue)
    
    // Test in Set
    let appSet: Set<MyAppInfo> = [app1, app2, app3]
    #expect(appSet.count == 2) // app1 and app2 should be considered equal
}

@Test func testMyAppInfoEquality() {
    let desc = LocalizedDescription(en: "Test app")
    let app1 = MyAppInfo(
        id: "com.test.app",
        name: "Test App",
        briefDescription: desc,
        appStoreID: "123",
        platforms: [.iOS]
    )
    
    let app2 = MyAppInfo(
        id: "com.test.app", // Same data
        name: "Test App",
        briefDescription: desc,
        appStoreID: "123",
        platforms: [.iOS]
    )
    
    let app3 = MyAppInfo(
        id: "com.test.different", // Different ID
        name: "Test App",
        briefDescription: desc,
        appStoreID: "123",
        platforms: [.iOS]
    )
    
    #expect(app1 == app2)
    #expect(app1 != app3)
}

@Test func testMyAppInfoCodable() throws {
    let original = MyAppInfo(
        id: "com.test.codable",
        name: "Codable Test",
        briefDescription: LocalizedDescription(en: "Test description", de: "Test Beschreibung"),
        iconURL: "https://example.com/icon.png",
        appStoreID: "555555555",
        platforms: [.iOS, .macOS, .visionOS]
    )
    
    // Encode to JSON
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try encoder.encode(original)
    
    // Verify JSON structure
    let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    #expect(jsonObject?["id"] as? String == "com.test.codable")
    #expect(jsonObject?["name"] as? String == "Codable Test")
    #expect(jsonObject?["iconURL"] as? String == "https://example.com/icon.png")
    #expect(jsonObject?["appStoreID"] as? String == "555555555")
    
    // Decode back
    let decoder = JSONDecoder()
    let decoded = try decoder.decode(MyAppInfo.self, from: data)
    
    #expect(decoded.id == original.id)
    #expect(decoded.name == original.name)
    #expect(decoded.iconURL == original.iconURL)
    #expect(decoded.appStoreID == original.appStoreID)
    #expect(decoded.platforms == original.platforms)
    #expect(decoded.briefDescription.en == original.briefDescription.en)
    #expect(decoded.briefDescription.de == original.briefDescription.de)
}

@Test func testMyAppInfoCodableWithoutOptionalFields() throws {
    let original = MyAppInfo(
        id: "com.test.minimal",
        name: "Minimal App",
        briefDescription: LocalizedDescription(en: "Simple app"),
        appStoreID: "999999999",
        platforms: [.iOS]
    )
    
    let encoder = JSONEncoder()
    let data = try encoder.encode(original)
    
    let decoder = JSONDecoder()
    let decoded = try decoder.decode(MyAppInfo.self, from: data)
    
    #expect(decoded.id == original.id)
    #expect(decoded.iconURL == nil)
    #expect(decoded.name == original.name)
    #expect(decoded.platforms == [.iOS])
}

@Test func testMyAppInfoWithMultiplePlatforms() {
    let allPlatforms: [Platform] = [.macOS, .iOS, .iPadOS, .watchOS, .tvOS, .visionOS]
    
    let appInfo = MyAppInfo(
        id: "com.test.multiplatform",
        name: "Multi-Platform App",
        briefDescription: LocalizedDescription(en: "Works everywhere"),
        appStoreID: "777777777",
        platforms: allPlatforms
    )
    
    #expect(appInfo.platforms.count == 6)
    #expect(appInfo.platforms.contains(.macOS))
    #expect(appInfo.platforms.contains(.iOS))
    #expect(appInfo.platforms.contains(.iPadOS))
    #expect(appInfo.platforms.contains(.watchOS))
    #expect(appInfo.platforms.contains(.tvOS))
    #expect(appInfo.platforms.contains(.visionOS))
}

@Test func testMyAppInfoWithEmptyPlatforms() {
    let appInfo = MyAppInfo(
        id: "com.test.noplatforms",
        name: "No Platform App",
        briefDescription: LocalizedDescription(en: "Platform-agnostic"),
        appStoreID: "000000000",
        platforms: []
    )
    
    #expect(appInfo.platforms.isEmpty)
}

// MARK: - MyAppsData Container Tests

@Test func testMyAppsDataInitialization() {
    let description = LocalizedDescription(en: "Test app description")
    let appInfo = MyAppInfo(
        id: "com.test.app",
        name: "Test App",
        briefDescription: description,
        appStoreID: "123456789",
        platforms: [.iOS]
    )
    
    let appsData = MyAppsData(
        version: "1.0",
        lastUpdated: "2025-08-04T12:00:00Z",
        apps: [appInfo]
    )

    #expect(appsData.version == "1.0")
    #expect(appsData.lastUpdated == "2025-08-04T12:00:00Z")
    #expect(appsData.apps.count == 1)
    #expect(appsData.apps.first?.name == "Test App")
}

@Test func testMyAppsDataWithMultipleApps() {
    let app1 = MyAppInfo(
        id: "com.test.app1",
        name: "First App",
        briefDescription: LocalizedDescription(en: "First app"),
        appStoreID: "111111111",
        platforms: [.iOS]
    )
    
    let app2 = MyAppInfo(
        id: "com.test.app2",
        name: "Second App",
        briefDescription: LocalizedDescription(en: "Second app"),
        appStoreID: "222222222",
        platforms: [.macOS]
    )
    
    let appsData = MyAppsData(
        version: "2.0",
        lastUpdated: "2025-08-04T15:30:00Z",
        apps: [app1, app2]
    )

    #expect(appsData.apps.count == 2)
    #expect(appsData.apps[0].name == "First App")
    #expect(appsData.apps[1].name == "Second App")
    #expect(appsData.apps[0].platforms == [.iOS])
    #expect(appsData.apps[1].platforms == [.macOS])
}

@Test func testMyAppsDataWithEmptyApps() {
    let emptyData = MyAppsData(
        version: "1.0",
        lastUpdated: "2025-08-04T00:00:00Z",
        apps: []
    )
    
    #expect(emptyData.apps.isEmpty)
    #expect(emptyData.version == "1.0")
    #expect(emptyData.lastUpdated == "2025-08-04T00:00:00Z")
}

@Test func testMyAppsDataCodable() throws {
    let app = MyAppInfo(
        id: "com.test.codable",
        name: "Codable App",
        briefDescription: LocalizedDescription(en: "Test"),
        appStoreID: "123",
        platforms: [.iOS]
    )
    
    let original = MyAppsData(
        version: "1.2.3",
        lastUpdated: "2025-08-04T10:30:45Z",
        apps: [app]
    )
    
    let encoder = JSONEncoder()
    let data = try encoder.encode(original)
    
    let decoder = JSONDecoder()
    let decoded = try decoder.decode(MyAppsData.self, from: data)
    
    #expect(decoded.version == original.version)
    #expect(decoded.lastUpdated == original.lastUpdated)
    #expect(decoded.apps.count == original.apps.count)
    #expect(decoded.apps.first?.name == "Codable App")
}

@Test func testMyAppsDataVersionFormats() {
    let testVersions = ["1.0", "1.0.0", "1.0.0-beta", "2.1.0-rc.1", "10.15.7"]
    
    for version in testVersions {
        let appsData = MyAppsData(
            version: version,
            lastUpdated: "2025-08-04T12:00:00Z",
            apps: []
        )
        
        #expect(appsData.version == version)
    }
}

@Test func testMyAppsDataDateFormats() {
    let testDates = [
        "2025-08-04T12:00:00Z",
        "2025-12-31T23:59:59Z",
        "2025-01-01T00:00:00Z",
        "2025-08-04T12:00:00.123Z"
    ]
    
    for dateString in testDates {
        let appsData = MyAppsData(
            version: "1.0",
            lastUpdated: dateString,
            apps: []
        )
        
        #expect(appsData.lastUpdated == dateString)
    }
}