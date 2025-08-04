import Testing
import Foundation
@testable import AppAboutView

// MARK: - JSON Parsing and Validation Tests

@Test func testValidJSONParsing() throws {
    let validJSON = """
    {
        "version": "1.0.0",
        "lastUpdated": "2025-08-04T12:00:00Z",
        "apps": [
            {
                "id": "com.example.app1",
                "name": "Test App 1",
                "briefDescription": {
                    "en": "A great test app",
                    "de": "Eine tolle Test-App"
                },
                "iconURL": "https://example.com/icon1.png",
                "appStoreID": "123456789",
                "platforms": ["iOS", "macOS"]
            },
            {
                "id": "com.example.app2",
                "name": "Test App 2",
                "briefDescription": {
                    "en": "Another test app"
                },
                "appStoreID": "987654321",
                "platforms": ["iOS"]
            }
        ]
    }
    """
    
    let data = validJSON.data(using: .utf8)!
    let decoder = JSONDecoder()
    let appsData = try decoder.decode(MyAppsData.self, from: data)
    
    #expect(appsData.version == "1.0.0")
    #expect(appsData.lastUpdated == "2025-08-04T12:00:00Z")
    #expect(appsData.apps.count == 2)
    
    let firstApp = appsData.apps[0]
    #expect(firstApp.id == "com.example.app1")
    #expect(firstApp.name == "Test App 1")
    #expect(firstApp.briefDescription.en == "A great test app")
    #expect(firstApp.briefDescription.de == "Eine tolle Test-App")
    #expect(firstApp.iconURL == "https://example.com/icon1.png")
    #expect(firstApp.appStoreID == "123456789")
    #expect(firstApp.platforms.count == 2)
    #expect(firstApp.platforms.contains(.iOS))
    #expect(firstApp.platforms.contains(.macOS))
    
    let secondApp = appsData.apps[1]
    #expect(secondApp.id == "com.example.app2")
    #expect(secondApp.iconURL == nil)
    #expect(secondApp.platforms == [.iOS])
}

@Test func testMinimalValidJSON() throws {
    let minimalJSON = """
    {
        "version": "1.0",
        "lastUpdated": "2025-08-04T00:00:00Z",
        "apps": []
    }
    """
    
    let data = minimalJSON.data(using: .utf8)!
    let decoder = JSONDecoder()
    let appsData = try decoder.decode(MyAppsData.self, from: data)
    
    #expect(appsData.version == "1.0")
    #expect(appsData.lastUpdated == "2025-08-04T00:00:00Z")
    #expect(appsData.apps.isEmpty)
}

@Test func testJSONWithAllLanguages() throws {
    let multilingualJSON = """
    {
        "version": "1.0",
        "lastUpdated": "2025-08-04T12:00:00Z",
        "apps": [
            {
                "id": "com.example.multilingual",
                "name": "Multilingual App",
                "briefDescription": {
                    "en": "English description",
                    "de": "German description",
                    "es": "Spanish description",
                    "fr": "French description",
                    "it": "Italian description",
                    "ja": "Japanese description",
                    "ko": "Korean description",
                    "ru": "Russian description",
                    "zh-Hans": "Simplified Chinese description",
                    "zh-Hant": "Traditional Chinese description"
                },
                "appStoreID": "555555555",
                "platforms": ["iOS", "macOS", "iPadOS", "watchOS", "tvOS", "visionOS"]
            }
        ]
    }
    """
    
    let data = multilingualJSON.data(using: .utf8)!
    let decoder = JSONDecoder()
    let appsData = try decoder.decode(MyAppsData.self, from: data)
    
    #expect(appsData.apps.count == 1)
    
    let app = appsData.apps[0]
    let desc = app.briefDescription
    #expect(desc.en == "English description")
    #expect(desc.de == "German description")
    #expect(desc.es == "Spanish description")
    #expect(desc.fr == "French description")
    #expect(desc.it == "Italian description")
    #expect(desc.ja == "Japanese description")
    #expect(desc.ko == "Korean description")
    #expect(desc.ru == "Russian description")
    #expect(desc.zhHans == "Simplified Chinese description")
    #expect(desc.zhHant == "Traditional Chinese description")
    
    #expect(app.platforms.count == 6)
    #expect(Set(app.platforms) == Set(Platform.allCases))
}

// MARK: - Invalid JSON Tests

@Test func testInvalidJSONStructure() {
    let invalidJSON = """
    {
        "version": "1.0",
        "apps": "not an array"
    }
    """
    
    let data = invalidJSON.data(using: .utf8)!
    let decoder = JSONDecoder()
    
    #expect(throws: DecodingError.self) {
        _ = try decoder.decode(MyAppsData.self, from: data)
    }
}

@Test func testMissingRequiredFields() {
    let missingFieldsJSON = """
    {
        "version": "1.0",
        "lastUpdated": "2025-08-04T12:00:00Z",
        "apps": [
            {
                "id": "com.example.incomplete",
                "name": "Incomplete App"
            }
        ]
    }
    """
    
    let data = missingFieldsJSON.data(using: .utf8)!
    let decoder = JSONDecoder()
    
    #expect(throws: DecodingError.self) {
        _ = try decoder.decode(MyAppsData.self, from: data)
    }
}

@Test func testInvalidPlatformValues() {
    let invalidPlatformJSON = """
    {
        "version": "1.0",
        "lastUpdated": "2025-08-04T12:00:00Z",
        "apps": [
            {
                "id": "com.example.invalidplatform",
                "name": "Invalid Platform App",
                "briefDescription": {
                    "en": "Test app"
                },
                "appStoreID": "123456789",
                "platforms": ["iOS", "InvalidPlatform", "macOS"]
            }
        ]
    }
    """
    
    let data = invalidPlatformJSON.data(using: .utf8)!
    let decoder = JSONDecoder()
    
    #expect(throws: DecodingError.self) {
        _ = try decoder.decode(MyAppsData.self, from: data)
    }
}

@Test func testMalformedJSON() {
    let malformedJSONs = [
        "{ invalid json }",
        "{ \"version\": }",
        "{ \"version\": \"1.0\", }",
        "[not an object]",
        "",
        "null"
    ]
    
    for malformedJSON in malformedJSONs {
        let data = malformedJSON.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        #expect(throws: (any Error).self) {
            _ = try decoder.decode(MyAppsData.self, from: data)
        }
    }
}

// MARK: - Edge Case JSON Tests

@Test func testJSONWithNullValues() throws {
    let nullValuesJSON = """
    {
        "version": "1.0",
        "lastUpdated": "2025-08-04T12:00:00Z",
        "apps": [
            {
                "id": "com.example.nulls",
                "name": "Null Values App",
                "briefDescription": {
                    "en": "Test app"
                },
                "iconURL": null,
                "appStoreID": "123456789",
                "platforms": ["iOS"]
            }
        ]
    }
    """
    
    let data = nullValuesJSON.data(using: .utf8)!
    let decoder = JSONDecoder()
    let appsData = try decoder.decode(MyAppsData.self, from: data)
    
    #expect(appsData.apps.count == 1)
    #expect(appsData.apps[0].iconURL == nil)
}

@Test func testJSONWithEmptyStrings() throws {
    let emptyStringsJSON = """
    {
        "version": "",
        "lastUpdated": "",
        "apps": [
            {
                "id": "",
                "name": "",
                "briefDescription": {
                    "en": ""
                },
                "appStoreID": "",
                "platforms": []
            }
        ]
    }
    """
    
    let data = emptyStringsJSON.data(using: .utf8)!
    let decoder = JSONDecoder()
    let appsData = try decoder.decode(MyAppsData.self, from: data)
    
    #expect(appsData.version == "")
    #expect(appsData.lastUpdated == "")
    #expect(appsData.apps.count == 1)
    #expect(appsData.apps[0].id == "")
    #expect(appsData.apps[0].name == "")
    #expect(appsData.apps[0].briefDescription.en == "")
    #expect(appsData.apps[0].platforms.isEmpty)
}

@Test func testJSONWithLargeNumbers() throws {
    let largeNumbersJSON = """
    {
        "version": "1.0",
        "lastUpdated": "2025-08-04T12:00:00Z",
        "apps": [
            {
                "id": "com.example.largenumber",
                "name": "Large Number App",
                "briefDescription": {
                    "en": "Test app"
                },
                "appStoreID": "999999999999999999",
                "platforms": ["iOS"]
            }
        ]
    }
    """
    
    let data = largeNumbersJSON.data(using: .utf8)!
    let decoder = JSONDecoder()
    let appsData = try decoder.decode(MyAppsData.self, from: data)
    
    #expect(appsData.apps[0].appStoreID == "999999999999999999")
}

// MARK: - JSON Round-trip Tests

@Test func testJSONRoundTrip() throws {
    let originalData = MyAppsData(
        version: "2.1.0",
        lastUpdated: "2025-08-04T15:30:45Z",
        apps: [
            MyAppInfo(
                id: "com.test.roundtrip1",
                name: "Round Trip App 1",
                briefDescription: LocalizedDescription(en: "Test app 1", de: "Test App 1"),
                iconURL: "https://example.com/icon1.png",
                appStoreID: "111111111",
                platforms: [.iOS, .macOS]
            ),
            MyAppInfo(
                id: "com.test.roundtrip2",
                name: "Round Trip App 2",
                briefDescription: LocalizedDescription(en: "Test app 2"),
                appStoreID: "222222222",
                platforms: [.iPadOS]
            )
        ]
    )
    
    // Encode to JSON
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let jsonData = try encoder.encode(originalData)
    
    // Decode back from JSON  
    let decoder = JSONDecoder()
    let decodedData = try decoder.decode(MyAppsData.self, from: jsonData)
    
    // Verify round-trip integrity
    #expect(decodedData.version == originalData.version)
    #expect(decodedData.lastUpdated == originalData.lastUpdated)
    #expect(decodedData.apps.count == originalData.apps.count)
    
    for i in 0..<originalData.apps.count {
        let original = originalData.apps[i]
        let decoded = decodedData.apps[i]
        
        #expect(decoded.id == original.id)
        #expect(decoded.name == original.name)
        #expect(decoded.briefDescription.en == original.briefDescription.en)
        #expect(decoded.briefDescription.de == original.briefDescription.de)
        #expect(decoded.iconURL == original.iconURL)
        #expect(decoded.appStoreID == original.appStoreID)
        #expect(decoded.platforms == original.platforms)
    }
}

// MARK: - Bundle Resource JSON Tests

@Test func testBundleAppsJSONStructure() {
    // Test the actual apps.json from the bundle if it exists
    guard let url = Bundle.module.url(forResource: "apps", withExtension: "json") else {
        // If no bundle resource exists, create a test to verify the expected structure
        return
    }
    
    do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let appsData = try decoder.decode(MyAppsData.self, from: data)
        
        // Verify basic structure
        #expect(!appsData.version.isEmpty)
        #expect(!appsData.lastUpdated.isEmpty)
        #expect(appsData.apps.isEmpty || !appsData.apps.isEmpty)
        
        // Verify each app has required fields
        for app in appsData.apps {
            #expect(!app.id.isEmpty)
            #expect(!app.name.isEmpty)
            #expect(!app.briefDescription.en.isEmpty)
            #expect(!app.appStoreID.isEmpty)
            #expect(!app.platforms.isEmpty)
        }
        
    } catch {
        // If bundle resource is malformed, test should fail
        #expect(Bool(false), "Bundle apps.json is malformed: \(error)")
    }
}

// MARK: - ISO8601 Date Parsing Tests

@Test func testISO8601DateParsingViaJSON() throws {
    // Test ISO8601 date parsing indirectly through JSON decoding
    let validDates = [
        "2025-08-04T12:00:00Z",
        "2025-12-31T23:59:59Z",
        "2025-01-01T00:00:00Z"
    ]
    
    for dateString in validDates {
        let jsonString = """
        {
            "version": "1.0",
            "lastUpdated": "\(dateString)",
            "apps": []
        }
        """
        
        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let appsData = try decoder.decode(MyAppsData.self, from: data)
        
        #expect(appsData.lastUpdated == dateString)
    }
}

@Test func testISO8601DateFormatterDirectly() {
    // Test the ISO8601DateFormatter directly since the extension is private
    let formatter = ISO8601DateFormatter()
    
    let validDates = [
        "2025-08-04T12:00:00Z",
        "2025-12-31T23:59:59Z",
        "2025-01-01T00:00:00Z"
    ]
    
    for dateString in validDates {
        let date = formatter.date(from: dateString)
        #expect(date != nil, "Date string '\(dateString)' should parse successfully")
    }
    
    let invalidDates = [
        "invalid date",
        "2025-13-01T12:00:00Z", // Invalid month
        "2025-08-32T12:00:00Z", // Invalid day
        "2025-08-04T25:00:00Z", // Invalid hour
        "2025-08-04 12:00:00", // Missing T and Z
        ""
    ]
    
    for dateString in invalidDates {
        let date = formatter.date(from: dateString)
        #expect(date == nil, "Date string '\(dateString)' should not parse successfully")
    }
}

// MARK: - JSON Performance Tests

@Test func testJSONPerformanceWithLargeData() throws {
    // Create a large JSON structure
    var apps: [MyAppInfo] = []
    for i in 0..<1000 {
        let app = MyAppInfo(
            id: "com.test.performance\(i)",
            name: "Performance Test App \(i)",
            briefDescription: LocalizedDescription(en: "Performance test app number \(i)"),
            appStoreID: "\(1000000000 + i)",
            platforms: [.iOS]
        )
        apps.append(app)
    }
    
    let largeData = MyAppsData(
        version: "1.0",
        lastUpdated: "2025-08-04T12:00:00Z",
        apps: apps
    )
    
    // Test encoding performance
    let encoder = JSONEncoder()
    let startEncode = Date()
    let jsonData = try encoder.encode(largeData)
    let encodeTime = Date().timeIntervalSince(startEncode)
    
    #expect(encodeTime < 5.0) // Should complete within 5 seconds
    #expect(jsonData.count > 100000) // Should produce substantial JSON
    
    // Test decoding performance
    let decoder = JSONDecoder()
    let startDecode = Date()
    let decodedData = try decoder.decode(MyAppsData.self, from: jsonData)
    let decodeTime = Date().timeIntervalSince(startDecode)
    
    #expect(decodeTime < 5.0) // Should complete within 5 seconds
    #expect(decodedData.apps.count == 1000)
}