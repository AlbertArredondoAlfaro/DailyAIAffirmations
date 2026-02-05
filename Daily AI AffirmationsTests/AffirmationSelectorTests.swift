//
//  AffirmationSelectorTests.swift
//  Daily AI AffirmationsTests
//
//  Created by Codex.
//

import Foundation
import Testing
@testable import Daily_AI_Affirmations

struct AffirmationSelectorTests {
    @Test func dailyIndexStartsAtZero() {
        let calendar = Calendar.gregorianUTC
        let date = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))!
        let index = AffirmationSelector.dailyIndex(for: date, count: 100, calendar: calendar)
        #expect(index == 0)
    }

    @Test func dailyIndexWrapsAtCount() {
        let calendar = Calendar.gregorianUTC
        let date = calendar.date(from: DateComponents(year: 2026, month: 1, day: 11))!
        let index = AffirmationSelector.dailyIndex(for: date, count: 10, calendar: calendar)
        #expect(index == 0)
    }

    @Test func languageDetectsSpanish() {
        let locale = Locale(identifier: "es_ES")
        #expect(AffirmationSelector.language(for: locale) == .spanish)
    }

    @Test func languageDefaultsToEnglish() {
        let locale = Locale(identifier: "fr_FR")
        #expect(AffirmationSelector.language(for: locale) == .english)
    }

    @Test func languageSpanishOutsideSpainIsEnglish() {
        let locale = Locale(identifier: "es_MX")
        #expect(AffirmationSelector.language(for: locale) == .english)
    }

    @Test func dailyAffirmationReturnsExpectedElement() {
        let calendar = Calendar.gregorianUTC
        let date = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))!
        let affirmation = AffirmationSelector.dailyAffirmation(for: date, language: .spanish, calendar: calendar)
        #expect(affirmation == AffirmationCatalog.spanish[0])
    }

    @Test func dailyAffirmationOmitsPlaceholdersWhenDisabled() {
        let calendar = Calendar.gregorianUTC
        let date = calendar.date(from: DateComponents(year: 2026, month: 2, day: 3))!
        let affirmation = AffirmationSelector.dailyAffirmation(
            for: date,
            language: .english,
            allowPlaceholders: false,
            calendar: calendar
        )
        #expect(!affirmation.contains("{name}"))
    }

    @Test func catalogFiltersPlaceholdersWhenDisabled() {
        let filtered = AffirmationSelector.catalog(for: .spanish, allowPlaceholders: false)
        #expect(!filtered.contains { $0.contains("{name}") })
        #expect(filtered.count < AffirmationCatalog.spanish.count)
    }

    @Test func dailyIndexHandlesLeapYear() {
        let calendar = Calendar.gregorianUTC
        let date = calendar.date(from: DateComponents(year: 2024, month: 12, day: 31))!
        let index = AffirmationSelector.dailyIndex(for: date, count: 365, calendar: calendar)
        #expect(index == 0)
    }

    @Test func randomAffirmationIsFromCatalog() {
        let affirmation = AffirmationSelector.randomAffirmation(language: .english)
        #expect(AffirmationCatalog.english.contains(affirmation))
    }

    @Test func randomAffirmationOmitsPlaceholdersWhenDisabled() {
        let affirmation = AffirmationSelector.randomAffirmation(language: .english, allowPlaceholders: false)
        #expect(!affirmation.contains("{name}"))
    }
}

private extension Calendar {
    static var gregorianUTC: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }
}
