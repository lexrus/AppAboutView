import Foundation

public struct LocalizedDescription: Codable, Hashable {
    public let en: String
    public let de: String?
    public let es: String?
    public let fr: String?
    public let it: String?
    public let ja: String?
    public let ko: String?
    public let nl: String?
    public let pt: String?
    public let no: String?
    public let th: String?
    public let tr: String?
    public let vi: String?
    public let sv: String?
    public let fi: String?
    public let ru: String?
    public let zhHans: String?
    public let zhHant: String?
    public let hi: String?
    public let pl: String?
    public let id: String?

    private enum CodingKeys: String, CodingKey {
        case en
        case de
        case es
        case fr
        case it
        case ja
        case ko
        case nl
        case pt
        case no
        case th
        case tr
        case vi
        case sv
        case fi
        case ru
        case zhHans = "zh-Hans"
        case zhHant = "zh-Hant"
        case hi
        case pl
        case id
    }

    public init(en: String, de: String? = nil, es: String? = nil, fr: String? = nil, it: String? = nil, ja: String? = nil, ko: String? = nil, nl: String? = nil, pt: String? = nil, no: String? = nil, th: String? = nil, tr: String? = nil, vi: String? = nil, sv: String? = nil, fi: String? = nil, ru: String? = nil, zhHans: String? = nil, zhHant: String? = nil, hi: String? = nil, pl: String? = nil, id: String? = nil) {
        self.en = en
        self.de = de
        self.es = es
        self.fr = fr
        self.it = it
        self.ja = ja
        self.ko = ko
        self.nl = nl
        self.pt = pt
        self.no = no
        self.th = th
        self.tr = tr
        self.vi = vi
        self.sv = sv
        self.fi = fi
        self.ru = ru
        self.zhHans = zhHans
        self.zhHant = zhHant
        self.hi = hi
        self.pl = pl
        self.id = id
    }

    public var localizedString: String {
        // Get the full language identifier including script if present
        let locale = Locale.current
        let languageCode = locale.language.languageCode?.identifier ?? "en"
        let script = locale.language.script?.identifier
        
        // Check for script-specific Chinese first (zh-Hans, zh-Hant)
        if languageCode == "zh" {
            // Check script identifier first (most reliable)
            if script == "Hans" {
                return zhHans ?? en
            } else if script == "Hant" {
                return zhHant ?? en
            }
            
            // Fallback to region-based detection
            let region = locale.language.region?.identifier
            if region == "CN" || region == "SG" || region == "MY" {
                return zhHans ?? en
            } else if region == "HK" || region == "TW" || region == "MO" {
                return zhHant ?? en
            }
            
            // Default to Simplified Chinese if no clear indicator
            // (This handles cases where user explicitly selected Simplified Chinese without region)
            return zhHans ?? en
        }
        
        switch languageCode {
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
        case "nl":
            return nl ?? en
        case "pt":
            return pt ?? en
        case "no", "nb", "nn":
            return no ?? en
        case "th":
            return th ?? en
        case "tr":
            return tr ?? en
        case "vi":
            return vi ?? en
        case "sv":
            return sv ?? en
        case "fi":
            return fi ?? en
        case "ru":
            return ru ?? en
        case "hi":
            return hi ?? en
        case "pl":
            return pl ?? en
        case "id":
            return id ?? en
        default:
            return en
        }
    }
}