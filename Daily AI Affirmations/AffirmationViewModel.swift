//
//  AffirmationViewModel.swift
//  Daily AI Affirmations
//
//  Created by Codex.
//

import Foundation
import Observation

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
        let detectedLanguage = AffirmationSelector.language(for: locale)
        self.language = detectedLanguage
        self.currentAffirmation = AffirmationSelector.dailyAffirmation(
            for: .now,
            language: detectedLanguage,
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
