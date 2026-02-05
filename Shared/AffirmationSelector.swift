//
//  AffirmationSelector.swift
//  Daily AI Affirmations
//
//  Created by Codex.
//

import Foundation

enum AffirmationLanguage {
    case spanish
    case english
}

enum AffirmationSelector {
    static func language(for locale: Locale) -> AffirmationLanguage {
        let languageCode = locale.language.languageCode?.identifier ?? "en"
        let regionCode = locale.region?.identifier ?? ""
        let identifier = locale.identifier

        let isSpain = regionCode == "ES" || identifier.hasPrefix("es_ES")
        return (languageCode == "es" && isSpain) ? .spanish : .english
    }

    static func catalog(for language: AffirmationLanguage) -> [String] {
        switch language {
        case .spanish:
            return AffirmationCatalog.spanish
        case .english:
            return AffirmationCatalog.english
        }
    }

    static func dailyIndex(for date: Date, count: Int, calendar: Calendar = .current) -> Int {
        guard count > 0 else { return 0 }
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        return (dayOfYear - 1) % count
    }

    static func dailyAffirmation(
        for date: Date,
        language: AffirmationLanguage,
        calendar: Calendar = .current
    ) -> String {
        let list = catalog(for: language)
        guard !list.isEmpty else { return "" }
        let index = dailyIndex(for: date, count: list.count, calendar: calendar)
        return list[index]
    }

    static func randomAffirmation(language: AffirmationLanguage) -> String {
        let list = catalog(for: language)
        return list.randomElement() ?? ""
    }
}
