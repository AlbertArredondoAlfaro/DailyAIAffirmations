//
//  CustomizationSheet.swift
//  Daily Affirmations
//
//  Created by Codex.
//

import SwiftUI
import UserNotifications

struct CustomizationSheet: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let nameLabel: String
    let useNameLabel: String
    let saveLabel: String
    let cancelLabel: String
    let validationMessage: String
    @Binding var name: String
    @Binding var useName: Bool
    @Binding var isPresented: Bool
    let notificationManager: NotificationManager
    let onSave: () -> Void
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var notificationsEnabled = false
    @State private var isCheckingNotifications = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            Spacer()
                            Button {
                                closeSheet()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(width: 40, height: 40)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.white)
                            .glassCircle()
                            .accessibilityLabel(Text(NSLocalizedString("customize_close", comment: "")))
                        }

                        VStack(spacing: 8) {
                            Text(title)
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(nameLabel)
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white.opacity(0.9))

                                TextField(nameLabel, text: $name)
                                    .textInputAutocapitalization(.words)
                                    .disableAutocorrection(true)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.white.opacity(0.16), lineWidth: 1)
                                    )
                                    .foregroundStyle(.white)
                                    .accessibilityHint(Text(validationMessage))

                                if isNameInvalid {
                                    Text(validationMessage)
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.75))
                                }
                            }

                            HStack(spacing: 12) {
                                Button {
                                    closeSheet()
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(.ultraThinMaterial)
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color.white.opacity(0.16), lineWidth: 1)
                                        Text(cancelLabel)
                                            .font(.system(.headline, design: .rounded))
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.white)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)

                            Button {
                                useName = !trimmedName.isEmpty
                                onSave()
                                Task {
                                    await refreshNotificationsIfEnabled()
                                }
                                closeSheet()
                            } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(.ultraThinMaterial)
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color.white.opacity(0.16), lineWidth: 1)
                                        Text(saveLabel)
                                            .font(.system(.headline, design: .rounded))
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.white)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .disabled(isSaveDisabled)
                                .opacity(isSaveDisabled ? 0.6 : 1.0)
                            }
                        }
                        .padding(18)
                        .background(Color.black.opacity(0.28), in: .rect(cornerRadius: 22))
                        .glassCard(cornerRadius: 22)

                        Text(NSLocalizedString("notification_section_title", comment: ""))
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)

                        notificationSection
                            .padding(18)
                            .background(Color.black.opacity(0.28), in: .rect(cornerRadius: 22))
                            .glassCard(cornerRadius: 22)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 24)
                    .padding(.bottom, 24)
                }
            }
            .ignoresSafeArea(edges: [.bottom])
        }
        .task {
            await refreshNotificationState()
        }
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isNameInvalid: Bool {
        trimmedName.isEmpty
    }

    private var isSaveDisabled: Bool {
        isNameInvalid
    }

    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if notificationStatus == .denied {
                Text(NSLocalizedString("notification_denied", comment: ""))
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))

                Button {
                    notificationManager.openSystemSettings()
                } label: {
                    Text(NSLocalizedString("notification_settings", comment: ""))
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(.ultraThinMaterial, in: .rect(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.16), lineWidth: 1)
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            } else {
                Toggle(isOn: Binding(
                    get: { notificationsEnabled },
                    set: { newValue in
                        notificationsEnabled = newValue
                        Task {
                            await updateNotifications(enabled: newValue)
                        }
                    }
                )) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(NSLocalizedString("notification_toggle", comment: ""))
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                        Text(NSLocalizedString("notification_time", comment: ""))
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                .toggleStyle(.switch)
                .tint(.white.opacity(0.85))
                .disabled(isCheckingNotifications)
                .opacity(isCheckingNotifications ? 0.6 : 1.0)

                Text(NSLocalizedString("notification_app_only", comment: ""))
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.65))
            }
        }
    }

    private func refreshNotificationState() async {
        isCheckingNotifications = true
        let status = await notificationManager.authorizationStatus()
        notificationStatus = status
        if notificationManager.isAuthorized(status) {
            notificationsEnabled = notificationManager.isEnabled
        } else {
            notificationsEnabled = false
        }
        isCheckingNotifications = false
    }

    private func updateNotifications(enabled: Bool) async {
        isCheckingNotifications = true
        let status = await notificationManager.authorizationStatus()
        notificationStatus = status

        if enabled {
            if status == .notDetermined {
                let granted = await notificationManager.requestAuthorization()
                notificationStatus = await notificationManager.authorizationStatus()
                if granted {
                    notificationManager.setEnabled(true)
                    await notificationManager.scheduleDailyAffirmations()
                    notificationsEnabled = true
                } else {
                    notificationManager.setEnabled(false)
                    notificationsEnabled = false
                }
            } else if notificationManager.isAuthorized(status) {
                notificationManager.setEnabled(true)
                await notificationManager.scheduleDailyAffirmations()
                notificationsEnabled = true
            } else {
                notificationManager.setEnabled(false)
                notificationsEnabled = false
            }
        } else {
            notificationManager.setEnabled(false)
            await notificationManager.cancelAll()
            notificationsEnabled = false
        }

        isCheckingNotifications = false
    }

    private func refreshNotificationsIfEnabled() async {
        let status = await notificationManager.authorizationStatus()
        guard notificationManager.isAuthorized(status) else { return }
        if notificationManager.isEnabled {
            await notificationManager.scheduleDailyAffirmations()
        }
    }

    private func closeSheet() {
        isPresented = false
    }
}
