//
//  AppBackground.swift
//  Daily Affirmations
//
//  Created by Codex.
//

import SwiftUI

struct AppBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.10, blue: 0.24),
                    Color(red: 0.12, green: 0.16, blue: 0.36),
                    Color(red: 0.18, green: 0.18, blue: 0.42)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.35, green: 0.60, blue: 0.95, opacity: 0.55),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 280, height: 280)
                .offset(x: 140, y: -180)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.58, green: 0.38, blue: 0.92, opacity: 0.45),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 220
                    )
                )
                .frame(width: 320, height: 320)
                .offset(x: -160, y: 220)
        }
        .ignoresSafeArea()
    }
}
