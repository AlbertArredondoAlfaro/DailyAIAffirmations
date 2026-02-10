//
//  Daily_Affirmations_WidgetBundle.swift
//  Daily Affirmations Widget
//
//  Created by Albert Bit Dj on 5/2/26.
//

import WidgetKit
import SwiftUI

@main
struct Daily_Affirmations_WidgetBundle: WidgetBundle {
    var body: some Widget {
        Daily_Affirmations_Widget()
        Daily_Affirmations_WidgetControl()
        Daily_Affirmations_WidgetLiveActivity()
    }
}
