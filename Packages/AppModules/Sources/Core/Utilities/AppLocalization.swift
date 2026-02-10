import Foundation

public enum AppLocalization {
    private static let lock = NSLock()
    private static var cachedLanguage: AppLanguage?

    private static func suiteDefaults() -> UserDefaults? {
        UserDefaults(suiteName: WordSearchConfig.suiteName)
    }

    private static func withLock<T>(_ body: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return body()
    }

    private static func setCachedLanguage(_ language: AppLanguage?) {
        withLock {
            cachedLanguage = language
        }
    }

    public static var currentLanguage: AppLanguage {
        if let cached = withLock({ cachedLanguage }) {
            return cached
        }

        let suiteRawValue = suiteDefaults()?.string(forKey: WordSearchConfig.appLanguageKey)
        if let suiteRawValue,
           let language = AppLanguage(rawValue: suiteRawValue) {
            setCachedLanguage(language)
            return language
        }

        let standardRawValue = UserDefaults.standard.string(forKey: WordSearchConfig.appLanguageKey)
        if let standardRawValue,
           let language = AppLanguage(rawValue: standardRawValue) {
            setCachedLanguage(language)
            return language
        }

        let resolved = AppLanguage.resolved()
        setCachedLanguage(resolved)
        return resolved
    }

    public static func setCurrentLanguage(_ language: AppLanguage) {
        setCachedLanguage(language)
        suiteDefaults()?.set(language.rawValue, forKey: WordSearchConfig.appLanguageKey)
        UserDefaults.standard.set(language.rawValue, forKey: WordSearchConfig.appLanguageKey)
    }

    static func resetCachedLanguageForTesting() {
        setCachedLanguage(nil)
    }

    public static var currentLocale: Locale {
        currentLanguage.locale
    }

    public static func localized(
        _ key: String,
        default defaultValue: String,
        bundle: Bundle,
        table: String? = nil
    ) -> String {
        let value = String(
            localized: String.LocalizationValue(key),
            table: table,
            bundle: bundle,
            locale: currentLocale,
            comment: ""
        )

        return value == key ? defaultValue : value
    }
}
