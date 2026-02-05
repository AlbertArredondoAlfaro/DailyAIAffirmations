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
    private enum DefaultsKey {
        static let customName = "customName"
        static let useCustomName = "useCustomName"
    }

    private let calendar: Calendar
    private let locale: Locale
    private let defaults: UserDefaults

    private(set) var language: AffirmationLanguage
    var currentAffirmation: String
    var customName: String = ""
    var useCustomName: Bool = false

    init(calendar: Calendar = .current, locale: Locale = .current, defaults: UserDefaults = .standard) {
        self.calendar = calendar
        self.locale = locale
        self.defaults = defaults
        let detectedLanguage = AffirmationSelector.language(for: locale)
        self.language = detectedLanguage
        let savedName = defaults.string(forKey: DefaultsKey.customName) ?? ""
        let savedUseName = defaults.bool(forKey: DefaultsKey.useCustomName)
        self.customName = savedName
        self.useCustomName = savedUseName
        self.currentAffirmation = AffirmationSelector.dailyAffirmation(
            for: .now,
            language: detectedLanguage,
            allowPlaceholders: savedUseName,
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

    var customizeTitle: String {
        language == .spanish ? "Personalizar afirmación" : "Customize affirmation"
    }

    var nameLabel: String {
        language == .spanish ? "Nombre" : "Name"
    }

    var useNameLabel: String {
        language == .spanish ? "Usar nombre en la frase" : "Use name in affirmation"
    }

    var saveLabel: String {
        language == .spanish ? "Guardar" : "Save"
    }

    var cancelLabel: String {
        language == .spanish ? "Cancelar" : "Cancel"
    }

    var nameValidationMessage: String {
        language == .spanish ? "Escribe un nombre para continuar." : "Enter a name to continue."
    }

    var displayAffirmation: String {
        guard useCustomName else { return currentAffirmation }
        let trimmed = customName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return currentAffirmation }
        return currentAffirmation.replacingOccurrences(of: "{name}", with: trimmed)
    }

    func saveCustomization(name: String, useName: Bool) {
        customName = name
        useCustomName = useName
        defaults.set(name, forKey: DefaultsKey.customName)
        defaults.set(useName, forKey: DefaultsKey.useCustomName)
        loadDaily()
    }

    func loadDaily(date: Date = .now) {
        let candidate = AffirmationSelector.dailyAffirmation(
            for: date,
            language: language,
            allowPlaceholders: useCustomName,
            calendar: calendar
        )
        currentAffirmation = sanitizedAffirmation(candidate)
    }

    func randomize() {
        let candidate = AffirmationSelector.randomAffirmation(
            language: language,
            allowPlaceholders: useCustomName
        )
        currentAffirmation = sanitizedAffirmation(candidate)
    }

    private func loadCustomization() {
        customName = defaults.string(forKey: DefaultsKey.customName) ?? ""
        useCustomName = defaults.bool(forKey: DefaultsKey.useCustomName)
    }

    private func sanitizedAffirmation(_ value: String) -> String {
        guard !useCustomName, value.contains("{name}") else { return value }
        let safeList = AffirmationSelector.catalog(for: language, allowPlaceholders: false)
        return safeList.randomElement() ?? value
    }
}
