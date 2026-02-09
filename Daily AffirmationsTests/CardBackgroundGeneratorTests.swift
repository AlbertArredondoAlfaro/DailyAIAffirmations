//
//  CardBackgroundGeneratorTests.swift
//  Daily AffirmationsTests
//
//  Created by Codex.
//

import XCTest
@testable import Daily_Affirmations

final class CardBackgroundGeneratorTests: XCTestCase {
    func testGeneratorProducesValidRanges() {
        var rng = SeededGenerator(seed: 42)
        let model = CardBackgroundGenerator.make(using: &rng)

        XCTAssertTrue(CardBackgroundGenerator.blobCountRange.contains(model.blobs.count))
        XCTAssertGreaterThanOrEqual(model.baseColors.count, 2)

        for blob in model.blobs {
            XCTAssertTrue(CardBackgroundGenerator.radiusRange.contains(Double(blob.radius)))
            XCTAssertTrue(CardBackgroundGenerator.opacityRange.contains(blob.opacity))
            XCTAssertTrue(CardBackgroundGenerator.centerXRange.contains(blob.center.x))
            XCTAssertTrue(CardBackgroundGenerator.centerYRange.contains(blob.center.y))
        }
    }
}

private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed == 0 ? 0xDEADBEEF : seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
