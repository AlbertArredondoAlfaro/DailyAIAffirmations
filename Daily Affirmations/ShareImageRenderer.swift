//
//  ShareImageRenderer.swift
//  Daily Affirmations
//
//  Created by Codex.
//

import SwiftUI

@MainActor
struct ShareImageRenderer {
    static func render(title: String, subtitle: String, text: String, scale: CGFloat) -> UIImage? {
        let renderer = ImageRenderer(content: ShareStoryView(
            title: title,
            subtitle: subtitle,
            text: text
        ))
        renderer.scale = 1
        return renderer.uiImage
    }
}

struct ShareStoryView: View {
    let title: String
    let subtitle: String
    let text: String

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 66, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text(subtitle)
                        .font(.system(size: 34, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                }
                .offset(y: 36)

                Spacer(minLength: 0)

                Text(text)
                    .font(.system(size: 76, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 80)

                Spacer(minLength: 0)

                Text("My Daily Affirmations")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(.top, 80)
            .padding(.bottom, 72)
            .padding(.horizontal, 48)
        }
        .frame(width: 1080, height: 1920)
    }
}

#Preview("Share Story") {
    ShareStoryView(
        title: "My Daily Affirmations",
        subtitle: "Your affirmation for today",
        text: "Respira paz, exhala tranquilidad."
    )
}
