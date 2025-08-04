import Foundation

public struct MyAppInfo: Codable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let briefDescription: LocalizedDescription
    public let iconURL: String?
    public let appStoreID: String
    public let platforms: [Platform]

    public init(
        id: String,
        name: String,
        briefDescription: LocalizedDescription,
        iconURL: String? = nil,
        appStoreID: String,
        platforms: [Platform]
    ) {
        self.id = id
        self.name = name
        self.briefDescription = briefDescription
        self.iconURL = iconURL
        self.appStoreID = appStoreID
        self.platforms = platforms
    }
}
