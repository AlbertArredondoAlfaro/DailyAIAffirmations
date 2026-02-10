//
//  AffirmationSelector.swift
//  Daily Affirmations
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

    static func catalog(for language: AffirmationLanguage, allowPlaceholders: Bool = true) -> [String] {
        let list: [String]
        switch language {
        case .spanish:
            list = AffirmationCatalog.spanish
        case .english:
            list = AffirmationCatalog.english
        }

        guard !allowPlaceholders else { return list }
        return list.filter { !$0.contains("{name}") }
    }

    static func dailyIndex(for date: Date, count: Int, calendar: Calendar = .current) -> Int {
        guard count > 0 else { return 0 }
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        return (dayOfYear - 1) % count
    }

    static func dailyAffirmation(
        for date: Date,
        language: AffirmationLanguage,
        allowPlaceholders: Bool = true,
        calendar: Calendar = .current
    ) -> String {
        let list = catalog(for: language, allowPlaceholders: allowPlaceholders)
        guard !list.isEmpty else { return "" }
        let index = dailyIndex(for: date, count: list.count, calendar: calendar)
        return list[index]
    }

    static func randomAffirmation(language: AffirmationLanguage, allowPlaceholders: Bool = true) -> String {
        let list = catalog(for: language, allowPlaceholders: allowPlaceholders)
        return list.randomElement() ?? ""
    }
}
