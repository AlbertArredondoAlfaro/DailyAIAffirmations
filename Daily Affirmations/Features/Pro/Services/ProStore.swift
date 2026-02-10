//
//  ProStore.swift
//  Daily Affirmations
//
//  Created by Codex.
//

import Combine
import Foundation
import StoreKit

struct ProTransaction {
    let productID: String
}

enum ProPurchaseResult {
    case successVerified
    case successUnverified
    case pending
    case userCancelled
}

struct ProProduct {
    let id: String
    let purchase: () async throws -> ProPurchaseResult
}

@MainActor
final class ProStore: ObservableObject {
    typealias ProductProvider = () async throws -> [ProProduct]
    typealias EntitlementsProvider = () -> AsyncStream<ProTransaction>
    typealias UpdatesProvider = () -> AsyncStream<ProTransaction>
    typealias SyncHandler = () async throws -> Void

    @Published private(set) var isPro: Bool
    @Published var lastErrorMessage: String?
    @Published var isProcessingPurchase = false

    private let productProvider: ProductProvider
    private let entitlementsProvider: EntitlementsProvider
    private let updatesProvider: UpdatesProvider
    private let syncHandler: SyncHandler
    private var updatesTask: Task<Void, Never>?

    init(
        productProvider: @escaping ProductProvider,
        entitlementsProvider: @escaping EntitlementsProvider,
        updatesProvider: @escaping UpdatesProvider,
        syncHandler: @escaping SyncHandler
    ) {
        self.productProvider = productProvider
        self.entitlementsProvider = entitlementsProvider
        self.updatesProvider = updatesProvider
        self.syncHandler = syncHandler
        self.isPro = ProStatus.isPro

        updatesTask = Task { [weak self] in
            await self?.refreshEntitlements()
            await self?.listenForTransactions()
        }
    }

    convenience init() {
        self.init(
            productProvider: {
                let products = try await Product.products(for: [ProStatus.productId])
                return products.map { product in
                    ProProduct(id: product.id) {
                        let result = try await product.purchase()
                        switch result {
                        case .success(let verification):
                            if case .verified(let transaction) = verification {
                                await transaction.finish()
                                return .successVerified
                            }
                            return .successUnverified
                        case .pending:
                            return .pending
                        case .userCancelled:
                            return .userCancelled
                        @unknown default:
                            return .userCancelled
                        }
                    }
                }
            },
            entitlementsProvider: {
                AsyncStream { continuation in
                    Task {
                        for await result in Transaction.currentEntitlements {
                            if case .verified(let transaction) = result {
                                continuation.yield(ProTransaction(productID: transaction.productID))
                            }
                        }
                        continuation.finish()
                    }
                }
            },
            updatesProvider: {
                AsyncStream { continuation in
                    Task {
                        for await result in Transaction.updates {
                            if case .verified(let transaction) = result {
                                continuation.yield(ProTransaction(productID: transaction.productID))
                            }
                        }
                        continuation.finish()
                    }
                }
            },
            syncHandler: {
                try await AppStore.sync()
            }
        )
    }

    deinit {
        updatesTask?.cancel()
    }

    func purchase() async {
        isProcessingPurchase = true
        defer { isProcessingPurchase = false }

        do {
            let products = try await productProvider()
            guard let product = products.first else {
                lastErrorMessage = NSLocalizedString("pro_error_product_missing", comment: "")
                return
            }
            let result = try await product.purchase()
            switch result {
            case .successVerified:
                await refreshEntitlements()
            case .successUnverified:
                lastErrorMessage = NSLocalizedString("pro_error_not_verified", comment: "")
            case .pending, .userCancelled:
                return
            }
        } catch {
            lastErrorMessage = NSLocalizedString("pro_error_generic", comment: "")
        }
    }

    func restore() async {
        isProcessingPurchase = true
        defer { isProcessingPurchase = false }

        do {
            try await syncHandler()
            await refreshEntitlements()
        } catch {
            lastErrorMessage = NSLocalizedString("pro_error_restore", comment: "")
        }
    }

    private func refreshEntitlements() async {
        var hasPro = false
        for await transaction in entitlementsProvider() {
            if transaction.productID == ProStatus.productId {
                hasPro = true
                break
            }
        }
        setProStatus(hasPro)
    }

    private func listenForTransactions() async {
        for await transaction in updatesProvider() {
            if transaction.productID == ProStatus.productId {
                setProStatus(true)
            }
        }
    }

    private func setProStatus(_ value: Bool) {
        if value {
            lastErrorMessage = nil
        }
        if isPro != value {
            isPro = value
        }
        ProStatus.isPro = value
    }
}
