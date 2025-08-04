import Foundation

public struct LocalizedDescription: Codable, Hashable {
    public let en: String
    public let de: String?
    public let es: String?
    public let fr: String?
    public let it: String?
    public let ja: String?
    public let ko: String?
    public let ru: String?
    public let zhHans: String?
    public let zhHant: String?

    private enum CodingKeys: String, CodingKey {
        case en
        case de
        case es
        case fr
        case it
        case ja
        case ko
        case ru
        case zhHans = "zh-Hans"
        case zhHant = "zh-Hant"
    }

    public init(en: String, de: String? = nil, es: String? = nil, fr: String? = nil, it: String? = nil, ja: String? = nil, ko: String? = nil, ru: String? = nil, zhHans: String? = nil, zhHant: String? = nil) {
        self.en = en
        self.de = de
        self.es = es
        self.fr = fr
        self.it = it
        self.ja = ja
        self.ko = ko
        self.ru = ru
        self.zhHans = zhHans
        self.zhHant = zhHant
    }

    public var localizedString: String {
        let currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"

        switch currentLanguage {
        case "de":
            return de ?? en
        case "es":
            return es ?? en
        case "fr":
            return fr ?? en
        case "it":
            return it ?? en
        case "ja":
            return ja ?? en
        case "ko":
            return ko ?? en
        case "ru":
            return ru ?? en
        case "zh":
            let region = Locale.current.language.region?.identifier
            if region == "CN" || region == "SG" {
                return zhHans ?? en
            } else {
                return zhHant ?? en
            }
        default:
            return en
        }
    }
}