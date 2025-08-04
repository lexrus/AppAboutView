import Foundation

public enum Platform: String, Codable, CaseIterable {
    case macOS = "macOS"
    case iOS = "iOS"
    case iPadOS = "iPadOS"
    case watchOS = "watchOS"
    case tvOS = "tvOS"
    case visionOS = "visionOS"

    public var displayName: String {
        switch self {
        case .macOS: return "macOS"
        case .iOS: return "iOS"
        case .iPadOS: return "iPadOS"
        case .watchOS: return "watchOS"
        case .tvOS: return "tvOS"
        case .visionOS: return "visionOS"
        }
    }

    public var systemImageName: String {
        switch self {
        case .macOS: return "desktopcomputer"
        case .iOS: return "iphone"
        case .iPadOS: return "ipad"
        case .watchOS: return "applewatch"
        case .tvOS: return "appletv"
        case .visionOS: return "visionpro"
        }
    }
}