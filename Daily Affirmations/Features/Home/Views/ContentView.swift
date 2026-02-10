//
//  ContentView.swift
//  Daily Affirmations
//
//  Created by Albert Bit Dj on 5/2/26.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.displayScale) private var displayScale
    @State private var model = AffirmationViewModel()
    @State private var shareItem: ShareItem?
    @State private var isCustomizePresented = false
    @State private var isProSheetPresented = false
    @State private var isProPromptPresented = false
    @State private var draftName = ""
    @State private var draftUseName = false
    @State private var cardBackground = CardBackgroundGenerator.make()
    @StateObject private var proStore = ProStore()
    @StateObject private var audioManager = AudioManager.shared
    private let notificationManager = NotificationManager.shared
    private let maxContentWidth: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 540 : .infinity
    private let maxCardHeight: CGFloat = 500
    private let minCardHeight: CGFloat = 340
    private let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad

    var body: some View {
        ZStack {
            AppBackground()
                .allowsHitTesting(false)

            VStack(spacing: 28) {
                header
                    .zIndex(2)

                AffirmationCard(
                    title: NSLocalizedString("app_title", comment: ""),
                    subtitle: model.subtitle,
                    text: model.displayAffirmation,
                    detailText: model.expandedAffirmation,
                    illustrationName: model.illustrationName,
                    background: cardBackground
                )
                .frame(maxWidth: maxContentWidth)
                .frame(minHeight: isPad ? nil : minCardHeight)
                .frame(height: isPad ? maxCardHeight : nil)
                .padding(.top, 36)
                .padding(.bottom, 36)

                actionRow

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 22)
            .padding(.top, 28)
            .padding(.bottom, 32)
            .frame(maxWidth: maxContentWidth)
            .frame(maxWidth: .infinity)
        }
        .safeAreaInset(edge: .bottom) {
            if !proStore.isPro {
                BannerAdContainer(adUnitID: AdMobConstants.bannerAdUnitID)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
            }
        }
        .task {
            model.loadDaily()
            await notificationManager.bootstrap()
            audioManager.startIfNeeded()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                model.loadDaily()
                RewardedAdManager.shared.appDidBecomeActive()
                audioManager.startIfNeeded()
                Task {
                    await notificationManager.refreshIfNeeded()
                }
            } else {
                audioManager.stop()
            }
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(items: [item.image])
        }
        .sheet(isPresented: $isCustomizePresented) {
            CustomizationSheet(
                title: model.customizeTitle,
                nameLabel: model.nameLabel,
                useNameLabel: model.useNameLabel,
                saveLabel: model.saveLabel,
                cancelLabel: model.cancelLabel,
                validationMessage: model.nameValidationMessage,
                name: $draftName,
                useName: $draftUseName,
                isPresented: $isCustomizePresented,
                notificationManager: notificationManager
            ) {
                model.saveCustomization(name: draftName, useName: draftUseName)
            }
        }
        .sheet(isPresented: $isProSheetPresented) {
            ProUpgradeSheet(
                proStore: proStore,
                onClose: { isProSheetPresented = false }
            )
        }
        .alert(NSLocalizedString("pro_prompt_title", comment: ""), isPresented: $isProPromptPresented) {
            Button(NSLocalizedString("pro_prompt_cta", comment: "")) {
                isProSheetPresented = true
            }
            Button(NSLocalizedString("pro_prompt_cancel", comment: ""), role: .cancel) {}
        } message: {
            Text(NSLocalizedString("pro_prompt_message", comment: ""))
        }
        .onReceive(NotificationCenter.default.publisher(for: ProNotifications.rewardedAdDidClose)) { _ in
            guard !proStore.isPro else { return }
            isProPromptPresented = true
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Spacer(minLength: 12)

                HStack(spacing: 10) {
                    audioToggleButton
                    shareButton
                    settingsButton
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(NSLocalizedString("app_title", comment: ""))
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                Text(model.tagline)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var audioToggleButton: some View {
        Button {
            audioManager.toggleMute()
        } label: {
            Image(systemName: audioManager.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                .font(.system(size: 18, weight: .semibold))
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .glassCircle()
        .accessibilityLabel(
            NSLocalizedString(audioManager.isMuted ? "audio_toggle_on" : "audio_toggle_off", comment: "")
        )
    }

    private var shareButton: some View {
        Button {
            guard let image = renderShareImage() else {
                return
            }
            shareItem = ShareItem(image: image)
        } label: {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 18, weight: .semibold))
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .glassCircle()
        .accessibilityLabel(NSLocalizedString("label_share", comment: ""))
    }

    private var settingsButton: some View {
        Button {
            isProSheetPresented = true
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 18, weight: .semibold))
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .glassCircle()
        .accessibilityLabel(NSLocalizedString("settings_accessibility", comment: ""))
    }

    private var actionRow: some View {
        Group {
            if #available(iOS 26, *) {
                GlassEffectContainer(spacing: 12) {
                    HStack(spacing: 12) {
                        Button {
                            model.randomize()
                        } label: {
                            Label(model.randomLabel, systemImage: "shuffle")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                        }
                        .accessibilityLabel(model.randomLabel)
                        .buttonStyle(.glass)

                        Button {
                            draftName = model.customName
                            draftUseName = model.useCustomName
                            isCustomizePresented = true
                        }
                        label: {
                            Label(model.customizeLabel, systemImage: "pencil")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                        }
                        .accessibilityLabel(model.customizeLabel)
                        .buttonStyle(.glass)
                    }
                }
            } else {
                HStack(spacing: 12) {
                    Button {
                        model.randomize()
                    } label: {
                        Label(model.randomLabel, systemImage: "shuffle")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                    }
                    .accessibilityLabel(model.randomLabel)
                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.white.opacity(0.14), lineWidth: 1)
                    )

                    Button {
                        draftName = model.customName
                        draftUseName = model.useCustomName
                        isCustomizePresented = true
                    }
                    label: {
                        Label(model.customizeLabel, systemImage: "pencil")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                    }
                    .accessibilityLabel(model.customizeLabel)
                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.white.opacity(0.14), lineWidth: 1)
                    )
                }
            }
        }
        .foregroundStyle(.white)
    }


    private func renderShareImage() -> UIImage? {
        ShareImageRenderer.render(
            title: NSLocalizedString("app_title", comment: ""),
            subtitle: model.subtitle,
            text: model.displayAffirmation,
            scale: displayScale
        )
    }
}

private struct ShareItem: Identifiable {
    let id = UUID()
    let image: UIImage
}

#Preview {
    ContentView()
}
