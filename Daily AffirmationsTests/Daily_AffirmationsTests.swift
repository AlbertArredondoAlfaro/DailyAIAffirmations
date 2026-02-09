//
//  Daily_AffirmationsTests.swift
//  Daily AffirmationsTests
//
//  Created by Albert Bit Dj on 5/2/26.
//

import Testing
@testable import Daily_Affirmations

struct Daily_AffirmationsTests {
    @Test func catalogHasExpectedCounts() {
        #expect(AffirmationCatalog.spanish.count == 365)
        #expect(AffirmationCatalog.english.count == 365)
    }
}
