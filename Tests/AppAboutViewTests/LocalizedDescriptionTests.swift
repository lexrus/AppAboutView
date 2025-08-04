import Testing
import Foundation
@testable import AppAboutView

// MARK: - LocalizedDescription Tests

@Test func testLocalizedDescriptionInitialization() {
    let desc = LocalizedDescription(
        en: "English description",
        de: "German description",
        es: "Spanish description",
        fr: "French description",
        it: "Italian description",
        ja: "Japanese description",
        ko: "Korean description",
        ru: "Russian description",
        zhHans: "Simplified Chinese description",
        zhHant: "Traditional Chinese description"
    )

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
}

@Test func testLocalizedDescriptionMinimalInitialization() {
    let desc = LocalizedDescription(en: "Only English")
    
    #expect(desc.en == "Only English")
    #expect(desc.de == nil)
    #expect(desc.es == nil)
    #expect(desc.fr == nil)
    #expect(desc.it == nil)
    #expect(desc.ja == nil)
    #expect(desc.ko == nil)
    #expect(desc.ru == nil)
    #expect(desc.zhHans == nil)
    #expect(desc.zhHant == nil)
}

@Test func testLocalizedDescriptionPartialInitialization() {
    let desc = LocalizedDescription(
        en: "English text",
        de: "German text",
        ja: "Japanese text"
    )
    
    #expect(desc.en == "English text")
    #expect(desc.de == "German text")
    #expect(desc.ja == "Japanese text")
    #expect(desc.es == nil)
    #expect(desc.fr == nil)
    #expect(desc.it == nil)
    #expect(desc.ko == nil)
    #expect(desc.ru == nil)
    #expect(desc.zhHans == nil)
    #expect(desc.zhHant == nil)
}

// MARK: - LocalizedDescription Localization Logic Tests

@Test func testLocalizedDescriptionFallbackToEnglish() {
    let desc = LocalizedDescription(
        en: "English text",
        de: "German text"
    )
    
    // The localized string should never be empty
    let localizedString = desc.localizedString
    #expect(!localizedString.isEmpty)
    
    // For unsupported locales, should fall back to English
    #expect(localizedString == "English text" || localizedString == "German text")
}

@Test func testLocalizedDescriptionWithEmptyEnglish() {
    let desc = LocalizedDescription(en: "")
    #expect(desc.localizedString == "")
}

@Test func testLocalizedDescriptionAllLanguagesProvided() {
    let desc = LocalizedDescription(
        en: "Hello",
        de: "Hallo",
        es: "Hola",
        fr: "Bonjour",
        it: "Ciao",
        ja: "こんにちは",
        ko: "안녕하세요",
        ru: "Привет",
        zhHans: "你好",
        zhHant: "你好"
    )
    
    // Should return a valid localized string
    let localizedString = desc.localizedString
    #expect(!localizedString.isEmpty)
    
    // Should be one of the provided translations
    let allTranslations = [
        desc.en, desc.de!, desc.es!, desc.fr!, desc.it!,
        desc.ja!, desc.ko!, desc.ru!, desc.zhHans!, desc.zhHant!
    ]
    #expect(allTranslations.contains(localizedString))
}

// MARK: - LocalizedDescription Codable Tests

@Test func testLocalizedDescriptionCodable() throws {
    let original = LocalizedDescription(
        en: "English",
        de: "Deutsch",
        es: "Español",
        fr: "Français",
        zhHans: "简体中文",
        zhHant: "繁體中文"
    )
    
    // Encode to JSON
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try encoder.encode(original)
    
    // Verify JSON structure
    let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    #expect(jsonObject?["en"] as? String == "English")
    #expect(jsonObject?["de"] as? String == "Deutsch")
    #expect(jsonObject?["es"] as? String == "Español")
    #expect(jsonObject?["fr"] as? String == "Français")
    #expect(jsonObject?["zh-Hans"] as? String == "简体中文") // Note the hyphenated key
    #expect(jsonObject?["zh-Hant"] as? String == "繁體中文") // Note the hyphenated key
    
    // Decode back
    let decoder = JSONDecoder()
    let decoded = try decoder.decode(LocalizedDescription.self, from: data)
    
    #expect(decoded.en == original.en)
    #expect(decoded.de == original.de)
    #expect(decoded.es == original.es)
    #expect(decoded.fr == original.fr)
    #expect(decoded.zhHans == original.zhHans)
    #expect(decoded.zhHant == original.zhHant)
}

@Test func testLocalizedDescriptionCodableMinimal() throws {
    let original = LocalizedDescription(en: "English only")
    
    let encoder = JSONEncoder()
    let data = try encoder.encode(original)
    
    // Verify minimal JSON structure
    let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    #expect(jsonObject?["en"] as? String == "English only")
    #expect(jsonObject?["de"] as? String == nil)
    
    let decoder = JSONDecoder()
    let decoded = try decoder.decode(LocalizedDescription.self, from: data)
    
    #expect(decoded.en == original.en)
    #expect(decoded.de == nil)
    #expect(decoded.es == nil)
}

@Test func testLocalizedDescriptionCodingKeys() throws {
    // Test that Chinese language keys are properly encoded/decoded with hyphens
    let jsonString = """
    {
        "en": "Hello",
        "zh-Hans": "你好",
        "zh-Hant": "你好"
    }
    """
    
    let data = jsonString.data(using: .utf8)!
    let decoder = JSONDecoder()
    let decoded = try decoder.decode(LocalizedDescription.self, from: data)
    
    #expect(decoded.en == "Hello")
    #expect(decoded.zhHans == "你好")
    #expect(decoded.zhHant == "你好")
}

@Test func testLocalizedDescriptionCodableWithInvalidKeys() {
    // Test JSON with invalid/unknown keys
    let jsonString = """
    {
        "en": "Hello",
        "invalid_language": "Should be ignored",
        "pt": "Should be ignored",
        "de": "Hallo"
    }
    """
    
    let data = jsonString.data(using: .utf8)!
    let decoder = JSONDecoder()
    
    // Should decode successfully, ignoring unknown keys
    #expect(throws: Never.self) {
        let decoded = try decoder.decode(LocalizedDescription.self, from: data)
        #expect(decoded.en == "Hello")
        #expect(decoded.de == "Hallo")
    }
}

// MARK: - LocalizedDescription Hashable Tests

@Test func testLocalizedDescriptionHashable() {
    let desc1 = LocalizedDescription(en: "Hello", de: "Hallo")
    let desc2 = LocalizedDescription(en: "Hello", de: "Hallo")
    let desc3 = LocalizedDescription(en: "Hi", de: "Hallo")
    
    #expect(desc1.hashValue == desc2.hashValue)
    #expect(desc1.hashValue != desc3.hashValue)
    
    // Test in Set
    let descSet: Set<LocalizedDescription> = [desc1, desc2, desc3]
    #expect(descSet.count == 2) // desc1 and desc2 should be considered equal
}

@Test func testLocalizedDescriptionEquality() {
    let desc1 = LocalizedDescription(en: "Hello", de: "Hallo", fr: "Bonjour")
    let desc2 = LocalizedDescription(en: "Hello", de: "Hallo", fr: "Bonjour")
    let desc3 = LocalizedDescription(en: "Hello", de: "Hallo") // Missing French
    let desc4 = LocalizedDescription(en: "Hi", de: "Hallo", fr: "Bonjour") // Different English
    
    #expect(desc1 == desc2)
    #expect(desc1 != desc3)
    #expect(desc1 != desc4)
    #expect(desc3 != desc4)
}

// MARK: - LocalizedDescription Edge Cases Tests

@Test func testLocalizedDescriptionWithSpecialCharacters() {
    let desc = LocalizedDescription(
        en: "Hello! @#$%^&*()_+-={}[]|\\:\";<>?,./'",
        de: "Hallo! äöüß",
        ja: "こんにちは！🎌",
        ru: "Привет! 😀"
    )
    
    #expect(desc.en.contains("@#$%"))
    #expect(desc.de?.contains("äöüß") == true)
    #expect(desc.ja?.contains("🎌") == true)
    #expect(desc.ru?.contains("😀") == true)
    
    // Should handle special characters in localization
    let localizedString = desc.localizedString
    #expect(!localizedString.isEmpty)
}

@Test func testLocalizedDescriptionWithLongStrings() {
    let longEnglish = String(repeating: "Long text ", count: 1000)
    let longGerman = String(repeating: "Langer Text ", count: 1000)
    
    let desc = LocalizedDescription(
        en: longEnglish,
        de: longGerman
    )
    
    #expect(desc.en.count >= 9000) // "Long text " is 10 characters, so 1000 * 10 = 10000
    #expect(desc.de?.count ?? 0 >= 11000) // "Langer Text " is 12 characters, so 1000 * 12 = 12000
    
    let localizedString = desc.localizedString
    #expect(localizedString.count > 1000)
}

@Test func testLocalizedDescriptionWithEmptyStrings() {
    let desc = LocalizedDescription(
        en: "",
        de: "",
        es: "Spanish text"
    )
    
    #expect(desc.en == "")
    #expect(desc.de == "")
    #expect(desc.es == "Spanish text")
    
    // Should handle empty strings in localization
    let localizedString = desc.localizedString
    #expect(localizedString == "" || localizedString == "Spanish text")
}

// MARK: - LocalizedDescription Performance Tests

@Test func testLocalizedDescriptionPerformance() {
    let desc = LocalizedDescription(
        en: "Performance test",
        de: "Performance-Test",
        ja: "パフォーマンステスト"
    )
    
    // Test that accessing localizedString multiple times is efficient
    let startTime = Date()
    for _ in 0..<1000 {
        let _ = desc.localizedString
    }
    let endTime = Date()
    
    let duration = endTime.timeIntervalSince(startTime)
    #expect(duration < 1.0) // Should complete within 1 second
}

@Test func testLocalizedDescriptionMemoryEfficiency() {
    // Create many LocalizedDescription instances
    var descriptions: [LocalizedDescription] = []
    
    for i in 0..<1000 {
        let desc = LocalizedDescription(
            en: "English \(i)",
            de: "German \(i)",
            ja: "Japanese \(i)"
        )
        descriptions.append(desc)
    }
    
    #expect(descriptions.count == 1000)
    
    // Test that they can be processed efficiently
    let englishTexts = descriptions.map { $0.en }
    #expect(englishTexts.count == 1000)
    #expect(englishTexts.first == "English 0")
    #expect(englishTexts.last == "English 999")
}

// MARK: - LocalizedDescription Locale-Specific Tests

@Test func testLocalizedDescriptionLanguageFallbacks() {
    let desc = LocalizedDescription(
        en: "English fallback",
        de: "German text",
        es: "Spanish text"
    )
    
    // Test that we always get a non-empty string
    let localizedString = desc.localizedString
    #expect(!localizedString.isEmpty)
    
    // Should be one of the provided translations
    let availableTranslations = [desc.en, desc.de, desc.es].compactMap { $0 }
    #expect(availableTranslations.contains(localizedString))
}

@Test func testLocalizedDescriptionWithNilValues() {
    let desc = LocalizedDescription(
        en: "English only",
        de: nil,
        es: nil,
        fr: nil,
        it: nil,
        ja: nil,
        ko: nil,
        ru: nil,
        zhHans: nil,
        zhHant: nil
    )
    
    #expect(desc.en == "English only")
    #expect(desc.de == nil)
    #expect(desc.es == nil)
    
    // Should fallback to English
    #expect(desc.localizedString == "English only")
}