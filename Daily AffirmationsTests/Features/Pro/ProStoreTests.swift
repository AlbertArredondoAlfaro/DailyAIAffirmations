//
//  ProStoreTests.swift
//  Daily AffirmationsTests
//
//  Created by Codex.
//

import XCTest
@testable import Daily_Affirmations

@MainActor
final class ProStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        ProStatus.isPro = false
        UserDefaults.standard.removeObject(forKey: "app.pro.enabled")
    }

    func testPurchaseMissingProductSetsError() async {
        let store = ProStore(
            productProvider: { [] },
            entitlementsProvider: { self.emptyStream() },
            updatesProvider: { self.emptyStream() },
            syncHandler: { }
        )

        await store.purchase()

        XCTAssertEqual(store.lastErrorMessage, NSLocalizedString("pro_error_product_missing", comment: ""))
        XCTAssertFalse(store.isPro)
    }

    func testPurchaseVerifiedSetsPro() async {
        let store = ProStore(
            productProvider: {
                [ProProduct(id: ProStatus.productId, purchase: { .successVerified })]
            },
            entitlementsProvider: { self.stream([ProTransaction(productID: ProStatus.productId)]) },
            updatesProvider: { self.emptyStream() },
            syncHandler: { }
        )

        await store.purchase()

        XCTAssertTrue(store.isPro)
        XCTAssertTrue(ProStatus.isPro)
    }

    func testRestoreFailureSetsError() async {
        struct TestError: Error {}
        let store = ProStore(
            productProvider: { [] },
            entitlementsProvider: { self.emptyStream() },
            updatesProvider: { self.emptyStream() },
            syncHandler: { throw TestError() }
        )

        await store.restore()

        XCTAssertEqual(store.lastErrorMessage, NSLocalizedString("pro_error_restore", comment: ""))
        XCTAssertFalse(store.isPro)
    }

    func testUpdatesSetPro() async {
        let store = ProStore(
            productProvider: { [] },
            entitlementsProvider: { self.emptyStream() },
            updatesProvider: { self.stream([ProTransaction(productID: ProStatus.productId)]) },
            syncHandler: { }
        )

        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertTrue(store.isPro)
    }

    private func emptyStream() -> AsyncStream<ProTransaction> {
        AsyncStream { continuation in
            continuation.finish()
        }
    }

    private func stream(_ items: [ProTransaction]) -> AsyncStream<ProTransaction> {
        AsyncStream { continuation in
            items.forEach { continuation.yield($0) }
            continuation.finish()
        }
    }
}
