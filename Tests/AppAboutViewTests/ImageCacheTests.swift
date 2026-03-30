import Testing
@testable import AppAboutView

@Test func testStableCacheKeyUsesDeterministicDigest() {
    let url = "https://example.com/icon.png"

    #expect(
        ImageCache.stableCacheKey(for: url) ==
            "4d2b6c4e8c53f5b51640c4e08a08b625b7437e866ee270599e3dcb61eedc028e"
    )
}

@Test func testStableCacheKeyChangesWhenURLChanges() {
    let originalURL = "https://example.com/icon.png"
    let updatedURL = "https://example.com/icon@2x.png"

    #expect(ImageCache.stableCacheKey(for: originalURL) != ImageCache.stableCacheKey(for: updatedURL))
}
