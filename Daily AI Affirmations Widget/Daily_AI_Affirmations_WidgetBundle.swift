//
//  Daily_AI_Affirmations_WidgetBundle.swift
//  Daily AI Affirmations Widget
//
//  Created by Albert Bit Dj on 5/2/26.
//

import WidgetKit
import SwiftUI

@main
struct Daily_AI_Affirmations_WidgetBundle: WidgetBundle {
    var body: some Widget {
        Daily_AI_Affirmations_Widget()
        Daily_AI_Affirmations_WidgetControl()
        Daily_AI_Affirmations_WidgetLiveActivity()
    }
}
