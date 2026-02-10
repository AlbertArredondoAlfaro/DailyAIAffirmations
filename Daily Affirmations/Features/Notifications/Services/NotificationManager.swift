//
//  NotificationManager.swift
//  Daily Affirmations
//
//  Created by Codex.
//

import Foundation
import UserNotifications
import UIKit

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()

    private enum DefaultsKey {
        static let requested = "notifications.requested"
        static let enabled = "notifications.enabled"
    }

    private let center: UNUserNotificationCenter
    private let calendar: Calendar
    private let locale: Locale
    private let defaults: UserDefaults

    init(
        center: UNUserNotificationCenter = .current(),
        calendar: Calendar = .current,
        locale: Locale = .current,
        defaults: UserDefaults = .standard
    ) {
        self.center = center
        self.calendar = calendar
        self.locale = locale
        self.defaults = defaults
    }

    func bootstrap() async {
        if defaults.bool(forKey: DefaultsKey.requested) {
            await refreshIfNeeded()
            return
        }

        defaults.set(true, forKey: DefaultsKey.requested)
        let granted = await requestAuthorization()
        if granted {
            defaults.set(true, forKey: DefaultsKey.enabled)
            await scheduleDailyAffirmations()
        } else {
            defaults.set(false, forKey: DefaultsKey.enabled)
        }
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        let settings = await notificationSettings()
        return settings.authorizationStatus
    }

    func isAuthorized(_ status: UNAuthorizationStatus) -> Bool {
        switch status {
        case .authorized, .provisional, .ephemeral:
            return true
        default:
            return false
        }
    }

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func refreshIfNeeded() async {
        guard isEnabled else { return }
        let status = await authorizationStatus()
        guard isAuthorized(status) else { return }

        let pending = await pendingDailyRequests()
        if pending.count < 2 {
            await scheduleDailyAffirmations()
        }
    }

    func hasPendingDailyNotifications() async -> Bool {
        guard isEnabled else { return false }
        let pending = await pendingDailyRequests()
        return !pending.isEmpty
    }

    func scheduleDailyAffirmations(daysAhead: Int = 7) async {
        guard isEnabled else { return }
        let status = await authorizationStatus()
        guard isAuthorized(status) else { return }

        await removePendingDailyRequests()
        let requests = makeRequests(startingFrom: Date(), daysAhead: daysAhead)
        for request in requests {
            do {
                try await center.add(request)
            } catch {
                continue
            }
        }
    }

    func cancelAll() async {
        await removePendingDailyRequests()
    }

    func setEnabled(_ enabled: Bool) {
        defaults.set(enabled, forKey: DefaultsKey.enabled)
    }

    var isEnabled: Bool {
        defaults.bool(forKey: DefaultsKey.enabled)
    }

    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    func makeRequests(startingFrom now: Date, daysAhead: Int) -> [UNNotificationRequest] {
        let language = AffirmationSelector.language(for: locale)
        let dates = notificationDates(startingFrom: now, daysAhead: daysAhead)

        return dates.compactMap { date in
            let body = dailyAffirmation(for: date, language: language)
            guard !body.isEmpty else { return nil }

            let content = UNMutableNotificationContent()
            content.title = NSLocalizedString("notification_title", comment: "")
            content.body = body
            content.sound = .default

            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let identifier = "daily-affirmation-\(Self.identifierDateFormatter.string(from: date))"

            return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        }
    }

    private func dailyAffirmation(for date: Date, language: AffirmationLanguage) -> String {
        let name = defaults.string(forKey: CustomizationDefaults.customNameKey) ?? ""
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let useName = defaults.bool(forKey: CustomizationDefaults.useNameKey)
        let allowPlaceholders = useName && !trimmed.isEmpty

        let raw = AffirmationSelector.dailyAffirmation(
            for: date,
            language: language,
            allowPlaceholders: allowPlaceholders,
            calendar: calendar
        )

        guard allowPlaceholders else { return raw }
        return raw.replacingOccurrences(of: "{name}", with: trimmed)
    }

    private func notificationDates(startingFrom now: Date, daysAhead: Int) -> [Date] {
        guard daysAhead > 0 else { return [] }

        let startOfDay = calendar.startOfDay(for: now)
        var firstTrigger = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: startOfDay) ?? now
        if now >= firstTrigger {
            firstTrigger = calendar.date(byAdding: .day, value: 1, to: firstTrigger) ?? firstTrigger
        }

        return (0..<daysAhead).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: firstTrigger)
        }
    }

    private func pendingDailyRequests() async -> [UNNotificationRequest] {
        let pending = await pendingRequests()
        return pending.filter { $0.identifier.hasPrefix("daily-affirmation-") }
    }

    private func removePendingDailyRequests() async {
        let pending = await pendingDailyRequests()
        let identifiers = pending.map(\.identifier)
        guard !identifiers.isEmpty else { return }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private func notificationSettings() async -> UNNotificationSettings {
        await withCheckedContinuation { continuation in
            center.getNotificationSettings { settings in
                continuation.resume(returning: settings)
            }
        }
    }

    private func pendingRequests() async -> [UNNotificationRequest] {
        await withCheckedContinuation { continuation in
            center.getPendingNotificationRequests { requests in
                continuation.resume(returning: requests)
            }
        }
    }

    private static let identifierDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = .current
        formatter.locale = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
