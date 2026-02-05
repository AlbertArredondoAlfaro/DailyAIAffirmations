//
//  ShareImageRendererTests.swift
//  Daily AI AffirmationsTests
//
//  Created by Codex.
//

import SwiftUI
import UIKit
import Testing
@testable import Daily_AI_Affirmations

@MainActor
struct ShareImageRendererTests {
    @Test func renderProducesImageWithExpectedSize() {
        let image = ShareImageRenderer.render(
            title: "Daily",
            subtitle: "Today",
            text: "You are doing great.",
            scale: 1.0
        )

        #expect(image != nil)
        #expect(image?.size == CGSize(width: 720, height: 720))
    }
}
