//
//  AffirmationExpansionGeneratorTests.swift
//  Daily AffirmationsTests
//
//  Created by Codex.
//

import XCTest
@testable import Daily_Affirmations

final class AffirmationExpansionGeneratorTests: XCTestCase {
    func testExpansionReturnsNonEmptyEnglish() {
        let text = "I choose calm today."
        let expansion = AffirmationExpansionGenerator.expand(affirmation: text, language: .english)
        XCTAssertFalse(expansion.isEmpty)
    }

    func testExpansionReturnsNonEmptySpanish() {
        let text = "Hoy elijo la calma."
        let expansion = AffirmationExpansionGenerator.expand(affirmation: text, language: .spanish)
        XCTAssertFalse(expansion.isEmpty)
    }

    func testExpansionEndsWithPunctuation() {
        let text = "I choose calm today"
        let expansion = AffirmationExpansionGenerator.expand(affirmation: text, language: .english)
        guard let last = expansion.last else {
            XCTFail("Empty expansion")
            return
        }
        XCTAssertTrue(".!?".contains(last))
    }
}
