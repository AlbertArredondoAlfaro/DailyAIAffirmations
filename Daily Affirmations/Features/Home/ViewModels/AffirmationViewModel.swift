//
//  AffirmationViewModel.swift
//  Daily Affirmations
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
    private let defaults: UserDefaults

    private(set) var language: AffirmationLanguage
    private(set) var currentDate: Date
    var currentAffirmation: String
    private var currentExpandedAffirmation: String
    private var currentIllustrationName: String
    var customName: String = ""
    var useCustomName: Bool = false

    init(calendar: Calendar = .current, locale: Locale = .current, defaults: UserDefaults = .standard) {
        self.calendar = calendar
        self.locale = locale
        self.defaults = defaults
        let detectedLanguage = AffirmationSelector.language(for: locale)
        self.language = detectedLanguage
        let savedName = defaults.string(forKey: CustomizationDefaults.customNameKey) ?? ""
        let savedUseName = defaults.bool(forKey: CustomizationDefaults.useNameKey)
        self.customName = savedName
        self.useCustomName = savedUseName
        let now = Date()
        self.currentDate = now
        let illustrationIndex = AffirmationSelector.dailyIndex(
            for: now,
            count: Self.illustrationNames.count,
            calendar: calendar
        )
        self.currentIllustrationName = Self.illustrationNames[illustrationIndex]
        self.currentAffirmation = AffirmationSelector.dailyAffirmation(
            for: now,
            language: detectedLanguage,
            allowPlaceholders: savedUseName,
            calendar: calendar
        )
        self.currentExpandedAffirmation = ""
        refreshExpandedAffirmation()
    }

    var subtitle: String {
        NSLocalizedString("subtitle_today", comment: "")
    }

    var tagline: String {
        NSLocalizedString("app_tagline", comment: "")
    }

    var randomLabel: String {
        NSLocalizedString("label_random", comment: "")
    }

    var customizeLabel: String {
        NSLocalizedString("label_customize", comment: "")
    }

    var customizeTitle: String {
        NSLocalizedString("customize_title", comment: "")
    }

    var nameLabel: String {
        NSLocalizedString("customize_name", comment: "")
    }

    var useNameLabel: String {
        NSLocalizedString("customize_use_name", comment: "")
    }

    var saveLabel: String {
        NSLocalizedString("customize_save", comment: "")
    }

    var cancelLabel: String {
        NSLocalizedString("customize_cancel", comment: "")
    }

    var nameValidationMessage: String {
        NSLocalizedString("customize_name_required", comment: "")
    }

    var displayAffirmation: String {
        guard useCustomName else { return currentAffirmation }
        let trimmed = customName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return currentAffirmation }
        return currentAffirmation.replacingOccurrences(of: "{name}", with: trimmed)
    }

    var expandedAffirmation: String {
        currentExpandedAffirmation
    }

    func saveCustomization(name: String, useName: Bool) {
        customName = name
        useCustomName = useName
        defaults.set(name, forKey: CustomizationDefaults.customNameKey)
        defaults.set(useName, forKey: CustomizationDefaults.useNameKey)
        loadDaily()
    }

    func loadDaily(date: Date = .now) {
        currentDate = date
        let candidate = AffirmationSelector.dailyAffirmation(
            for: date,
            language: language,
            allowPlaceholders: useCustomName,
            calendar: calendar
        )
        currentAffirmation = sanitizedAffirmation(candidate)
        let illustrationIndex = AffirmationSelector.dailyIndex(
            for: date,
            count: Self.illustrationNames.count,
            calendar: calendar
        )
        currentIllustrationName = Self.illustrationNames[illustrationIndex]
        refreshExpandedAffirmation()
    }

    var illustrationName: String {
        currentIllustrationName
    }

    func randomize() {
        let candidate = AffirmationSelector.randomAffirmation(
            language: language,
            allowPlaceholders: useCustomName
        )
        currentAffirmation = sanitizedAffirmation(candidate)
        currentIllustrationName = Self.illustrationNames.randomElement() ?? currentIllustrationName
        refreshExpandedAffirmation()
    }

    private func loadCustomization() {
        customName = defaults.string(forKey: CustomizationDefaults.customNameKey) ?? ""
        useCustomName = defaults.bool(forKey: CustomizationDefaults.useNameKey)
    }

    private func sanitizedAffirmation(_ value: String) -> String {
        guard !useCustomName, value.contains("{name}") else { return value }
        let safeList = AffirmationSelector.catalog(for: language, allowPlaceholders: false)
        return safeList.randomElement() ?? value
    }

    private func refreshExpandedAffirmation() {
        currentExpandedAffirmation = AffirmationExpansionGenerator.expand(
            affirmation: displayAffirmation,
            language: language
        )
    }

    private static let illustrationNames: [String] = (1...20).map {
        String(format: "AffirmationIllustration%02d", $0)
    }
}
