//
//  AffirmationViewModelTests.swift
//  Daily AI AffirmationsTests
//
//  Created by Codex.
//

import Foundation
import Testing
@testable import Daily_AI_Affirmations

@MainActor
struct AffirmationViewModelTests {
    @Test func initLoadsSavedCustomization() {
        let defaults = UserDefaults(suiteName: "AffirmationViewModelTests.init")!
        defaults.removePersistentDomain(forName: "AffirmationViewModelTests.init")
        defaults.set("Alex", forKey: "customName")
        defaults.set(true, forKey: "useCustomName")

        let model = AffirmationViewModel(
            calendar: Calendar.gregorianUTC,
            locale: Locale(identifier: "en_US"),
            defaults: defaults
        )

        #expect(model.customName == "Alex")
        #expect(model.useCustomName == true)
    }

    @Test func saveCustomizationPersistsAndUpdatesAffirmation() {
        let defaults = UserDefaults(suiteName: "AffirmationViewModelTests.save")!
        defaults.removePersistentDomain(forName: "AffirmationViewModelTests.save")

        let model = AffirmationViewModel(
            calendar: Calendar.gregorianUTC,
            locale: Locale(identifier: "en_US"),
            defaults: defaults
        )

        model.saveCustomization(name: "Jamie", useName: true)

        #expect(defaults.string(forKey: "customName") == "Jamie")
        #expect(defaults.bool(forKey: "useCustomName") == true)
        #expect(model.useCustomName == true)
    }

    @Test func displayAffirmationReplacesName() {
        let defaults = UserDefaults(suiteName: "AffirmationViewModelTests.display")!
        defaults.removePersistentDomain(forName: "AffirmationViewModelTests.display")

        let model = AffirmationViewModel(
            calendar: Calendar.gregorianUTC,
            locale: Locale(identifier: "en_US"),
            defaults: defaults
        )

        model.currentAffirmation = "Hello, {name}!"
        model.customName = "  Taylor  "
        model.useCustomName = true

        #expect(model.displayAffirmation == "Hello, Taylor!")
    }

    @Test func displayAffirmationSkipsEmptyName() {
        let defaults = UserDefaults(suiteName: "AffirmationViewModelTests.empty")!
        defaults.removePersistentDomain(forName: "AffirmationViewModelTests.empty")

        let model = AffirmationViewModel(
            calendar: Calendar.gregorianUTC,
            locale: Locale(identifier: "en_US"),
            defaults: defaults
        )

        model.currentAffirmation = "Hello, {name}!"
        model.customName = "   "
        model.useCustomName = true

        #expect(model.displayAffirmation == "Hello, {name}!")
    }

    @Test func loadDailyOmitsPlaceholdersWhenDisabled() {
        let defaults = UserDefaults(suiteName: "AffirmationViewModelTests.daily")!
        defaults.removePersistentDomain(forName: "AffirmationViewModelTests.daily")

        let model = AffirmationViewModel(
            calendar: Calendar.gregorianUTC,
            locale: Locale(identifier: "en_US"),
            defaults: defaults
        )

        model.useCustomName = false
        model.loadDaily(date: Calendar.gregorianUTC.date(from: DateComponents(year: 2026, month: 3, day: 5))!)
        #expect(!model.currentAffirmation.contains("{name}"))
    }
}

private extension Calendar {
    static var gregorianUTC: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }
}
