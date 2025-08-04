import Foundation

@MainActor
public class AppShowcaseService: ObservableObject {
    @Published public private(set) var apps: [MyAppInfo] = []
    @Published public private(set) var lastUpdated: Date?

    private let remoteURL: URL?
    private let currentAppStoreID: String?
    private let cacheKey = "cachedMyAppsData"
    private let lastFetchKey = "lastAppsFetchDate"

    public init(remoteURL: URL? = nil, currentAppStoreID: String? = nil) {
        self.remoteURL = remoteURL
        self.currentAppStoreID = currentAppStoreID
        loadApps()
    }

    public func loadApps() {
        loadLocalApps()
        loadCachedApps()
    }

    public func fetchRemoteAppsIfNeeded() {
        guard let remoteURL = remoteURL else { return }

        let lastFetch = UserDefaults.standard.object(forKey: lastFetchKey) as? Date

        #if DEBUG
        let shouldFetch = true
        #else
        let shouldFetch = lastFetch == nil || Date().timeIntervalSince(lastFetch!) > 3600 // 1 hour
        #endif

        if shouldFetch {
            Task {
                await fetchRemoteApps(from: remoteURL)
            }
        }
    }

    private func loadLocalApps() {
        guard let url = Bundle.module.url(forResource: "apps", withExtension: "json") else {
            print("Failed to find apps.json in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let appsData = try JSONDecoder().decode(MyAppsData.self, from: data)
            self.apps = filterCurrentApp(from: appsData.apps)

            if let dateString = appsData.lastUpdated.iso8601Date {
                self.lastUpdated = dateString
            }
        } catch {
            print("Failed to load local apps: \(error)")
        }
    }

    private func loadCachedApps() {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else { return }

        do {
            let appsData = try JSONDecoder().decode(MyAppsData.self, from: data)
            self.apps = filterCurrentApp(from: appsData.apps)

            if let dateString = appsData.lastUpdated.iso8601Date {
                self.lastUpdated = dateString
            }
        } catch {
            print("Failed to load cached apps: \(error)")
        }
    }

    private func fetchRemoteApps(from url: URL) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let appsData = try JSONDecoder().decode(MyAppsData.self, from: data)

            UserDefaults.standard.set(data, forKey: cacheKey)
            UserDefaults.standard.set(Date(), forKey: lastFetchKey)

            self.apps = filterCurrentApp(from: appsData.apps)

            if let dateString = appsData.lastUpdated.iso8601Date {
                self.lastUpdated = dateString
            }
        } catch {
            print("Failed to fetch remote apps: \(error)")
        }
    }

    private func filterCurrentApp(from apps: [MyAppInfo]) -> [MyAppInfo] {
        guard let currentAppStoreID else {
            return apps
        }
        return apps.filter { $0.appStoreID != currentAppStoreID }
    }
}

private extension String {
    var iso8601Date: Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: self)
    }
}
