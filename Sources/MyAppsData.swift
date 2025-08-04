import Foundation

public struct MyAppsData: Codable {
    public let version: String
    public let lastUpdated: String
    public let apps: [MyAppInfo]

    public init(version: String, lastUpdated: String, apps: [MyAppInfo]) {
        self.version = version
        self.lastUpdated = lastUpdated
        self.apps = apps
    }
}