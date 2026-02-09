//
//  ContentView.swift
//  Daily AI Affirmations
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
    @State private var draftName = ""
    @State private var draftUseName = false

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 28) {
                header

                AffirmationCard(
                    title: NSLocalizedString("app_title", comment: ""),
                    subtitle: model.subtitle,
                    text: model.displayAffirmation
                )
                .padding(.top, 36)
                .padding(.bottom, 36)

                actionRow

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 22)
            .padding(.top, 28)
            .padding(.bottom, 32)
        }
        .safeAreaInset(edge: .bottom) {
            BannerAdContainer(adUnitID: AdMobConstants.bannerAdUnitID)
                .padding(.horizontal, 22)
                .padding(.vertical, 12)
        }
        .task {
            model.loadDaily()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            model.loadDaily()
            RewardedAdManager.shared.appDidBecomeActive()
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
                useName: $draftUseName
            ) {
                model.saveCustomization(name: draftName, useName: draftUseName)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(NSLocalizedString("app_title", comment: ""))
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                Text(model.tagline)
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
            }

            Spacer(minLength: 12)

            shareButton
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var shareButton: some View {
        Button {
            guard let image = renderShareImage() else { return }
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

private struct CustomizationSheet: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let nameLabel: String
    let useNameLabel: String
    let saveLabel: String
    let cancelLabel: String
    let validationMessage: String
    @Binding var name: String
    @Binding var useName: Bool
    let onSave: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 8) {
                            Text(title)
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)

                            Text(validationMessage)
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundStyle(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text(nameLabel)
                                .font(.system(.headline, design: .rounded))
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
                        .padding(18)
                        .glassCard(cornerRadius: 22)

                        VStack(alignment: .leading, spacing: 12) {
                            Toggle(isOn: $useName) {
                                Text(useNameLabel)
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            }
                            .toggleStyle(.switch)
                            .tint(.white.opacity(0.85))
                        }
                        .padding(18)
                        .glassCard(cornerRadius: 22)

                        HStack(spacing: 12) {
                            Button {
                                dismiss()
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
                                onSave()
                                dismiss()
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
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 24)
                    .padding(.bottom, 24)
                }
            }
            .ignoresSafeArea(edges: [.bottom])
        }
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isNameInvalid: Bool {
        useName && trimmedName.isEmpty
    }

    private var isSaveDisabled: Bool {
        isNameInvalid
    }
}

private struct ShareItem: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct AffirmationCard: View {
    let title: String
    let subtitle: String
    let text: String

    var body: some View {
        cardContent
            .glassCard(cornerRadius: 26)
    }

    private var cardContent: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.black.opacity(0.28))

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .center, spacing: 8) {
                    Text(subtitle)
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 2)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                .padding(.top, 18)

                Spacer(minLength: 8)

                Text(text)
                    .font(.system(size: 26, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.98))
                    .lineSpacing(4)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 3)
                    .frame(maxWidth: .infinity, alignment: .center)

                Spacer(minLength: 0)
            }
            .padding(22)
            .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

struct AppBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.10, blue: 0.24),
                    Color(red: 0.12, green: 0.16, blue: 0.36),
                    Color(red: 0.18, green: 0.18, blue: 0.42)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.35, green: 0.60, blue: 0.95, opacity: 0.55),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 280, height: 280)
                .offset(x: 140, y: -180)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.58, green: 0.38, blue: 0.92, opacity: 0.45),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 220
                    )
                )
                .frame(width: 320, height: 320)
                .offset(x: -160, y: 220)
        }
        .ignoresSafeArea()
    }
}

private extension View {
    @ViewBuilder
    func glassCard(cornerRadius: CGFloat) -> some View {
        if #available(iOS 26, *) {
            self
                .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            self
                .background(.ultraThinMaterial, in: .rect(cornerRadius: cornerRadius))
        }
    }

    @ViewBuilder
    func glassCircle() -> some View {
        if #available(iOS 26, *) {
            self
                .glassEffect(.regular.interactive(), in: .circle)
        } else {
            self
                .background(.ultraThinMaterial, in: Circle())
        }
    }
}

#Preview {
    ContentView()
}
