import Testing
@testable import AppAboutView

@Test @MainActor func testImageCacheKeyIsDeterministic() {
    let url = "https://example.com/icons/app.png?size=512"
    let expectedKey = "977c83dd78056fd3f76a61e528d4a2fd3d48f3c9614e1ad4033613780ebe01b2"

    #expect(ImageCache.cacheKey(for: url) == expectedKey)
    #expect(ImageCache.cacheKey(for: url) == ImageCache.cacheKey(for: url))
}
