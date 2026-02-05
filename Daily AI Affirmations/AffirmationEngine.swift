//
//  AffirmationEngine.swift
//  Daily AI Affirmations
//
//  Created by Codex.
//

import Foundation
import Observation

enum AffirmationLanguage {
    case spanish
    case english
}

enum AffirmationSelector {
    static func language(for locale: Locale) -> AffirmationLanguage {
        let code = locale.language.languageCode?.identifier ?? "en"
        return code.hasPrefix("es") ? .spanish : .english
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

@MainActor
@Observable
final class AffirmationViewModel {
    private let calendar: Calendar
    private let locale: Locale

    private(set) var language: AffirmationLanguage
    var currentAffirmation: String

    init(calendar: Calendar = .current, locale: Locale = .current) {
        self.calendar = calendar
        self.locale = locale
        self.language = AffirmationSelector.language(for: locale)
        self.currentAffirmation = AffirmationSelector.dailyAffirmation(
            for: .now,
            language: self.language,
            calendar: calendar
        )
    }

    var subtitle: String {
        language == .spanish ? "Tu afirmación de hoy" : "Your affirmation for today"
    }

    var tagline: String {
        language == .spanish ? "Respira. Conecta. Avanza." : "Breathe. Connect. Move forward."
    }

    var randomLabel: String {
        language == .spanish ? "Aleatoria" : "Random"
    }

    var customizeLabel: String {
        language == .spanish ? "Personalizar" : "Customize"
    }

    func loadDaily(date: Date = .now) {
        currentAffirmation = AffirmationSelector.dailyAffirmation(
            for: date,
            language: language,
            calendar: calendar
        )
    }

    func randomize() {
        currentAffirmation = AffirmationSelector.randomAffirmation(language: language)
    }
}
