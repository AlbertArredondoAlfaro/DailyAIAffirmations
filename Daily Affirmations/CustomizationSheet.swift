//
//  CustomizationSheet.swift
//  Daily Affirmations
//
//  Created by Codex.
//

import SwiftUI

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
