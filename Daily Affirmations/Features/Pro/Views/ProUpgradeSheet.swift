//
//  ProUpgradeSheet.swift
//  Daily Affirmations
//
//  Created by Codex.
//

import SwiftUI

struct ProUpgradeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var proStore: ProStore
    let onClose: () -> Void
    @State private var isErrorPresented = false
    @State private var activeAction: ProAction?

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        Text(NSLocalizedString("pro_title", comment: ""))
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text(NSLocalizedString("pro_subtitle", comment: ""))
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: 12) {
                        Button {
                            Task {
                                activeAction = .purchase
                                defer { activeAction = nil }
                                await proStore.purchase()
                                if proStore.isPro {
                                    dismiss()
                                    onClose()
                                }
                            }
                        } label: {
                            ZStack {
                                Text(buyButtonTitle)
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.semibold)
                                    .opacity(isLoadingPurchase ? 0 : 1)

                                if isLoadingPurchase {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .tint(.black)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .background(.white.opacity(0.95), in: .rect(cornerRadius: 18))
                        .foregroundStyle(.black)
                        .disabled(proStore.isProcessingPurchase || proStore.productDisplayPrice == nil)

                        Button {
                            Task {
                                activeAction = .restore
                                defer { activeAction = nil }
                                await proStore.restore()
                                if proStore.isPro {
                                    dismiss()
                                    onClose()
                                }
                            }
                        } label: {
                            ZStack {
                                Text(NSLocalizedString("pro_restore_mock", comment: ""))
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.semibold)
                                    .opacity(isLoadingRestore ? 0 : 1)

                                if isLoadingRestore {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .tint(.black)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .background(.white.opacity(0.95), in: .rect(cornerRadius: 18))
                        .foregroundStyle(.black)
                        .disabled(proStore.isProcessingPurchase)
                    }
                    .padding(18)
                    .glassCard(cornerRadius: 22)

                    Button(NSLocalizedString("pro_close", comment: "")) {
                        dismiss()
                        onClose()
                    }
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .disabled(proStore.isProcessingPurchase)
                    .opacity(proStore.isProcessingPurchase ? 0.6 : 1.0)
                }
                .padding(.horizontal, 22)
                .padding(.top, 24)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .ignoresSafeArea()
            .alert(NSLocalizedString("pro_error_title", comment: ""), isPresented: $isErrorPresented) {
                Button(NSLocalizedString("pro_error_ok", comment: ""), role: .cancel) {}
            } message: {
                Text(proStore.lastErrorMessage ?? NSLocalizedString("pro_error_generic", comment: ""))
            }
            .task {
                await proStore.loadProduct()
            }
            .onChange(of: proStore.lastErrorMessage) { _, newValue in
                isErrorPresented = (newValue != nil)
            }
        }
    }

    private var buyButtonTitle: String {
        guard let price = proStore.productDisplayPrice else {
            return NSLocalizedString("pro_buy_loading", comment: "")
        }
        let format = NSLocalizedString("pro_buy_with_price", comment: "")
        return String(format: format, price)
    }

    private var isLoadingPurchase: Bool {
        proStore.isProcessingPurchase && activeAction == .purchase
    }

    private var isLoadingRestore: Bool {
        proStore.isProcessingPurchase && activeAction == .restore
    }
}

private enum ProAction {
    case purchase
    case restore
}
