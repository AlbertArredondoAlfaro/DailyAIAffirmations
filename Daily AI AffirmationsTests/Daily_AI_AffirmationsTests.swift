//
//  Daily_AI_AffirmationsTests.swift
//  Daily AI AffirmationsTests
//
//  Created by Albert Bit Dj on 5/2/26.
//

import Testing
@testable import Daily_AI_Affirmations

struct Daily_AI_AffirmationsTests {
    @Test func catalogHasExpectedCounts() {
        #expect(AffirmationCatalog.spanish.count == 100)
        #expect(AffirmationCatalog.english.count == 100)
    }
}
