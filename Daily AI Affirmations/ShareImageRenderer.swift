//
//  ShareImageRenderer.swift
//  Daily AI Affirmations
//
//  Created by Codex.
//

import SwiftUI

@MainActor
struct ShareImageRenderer {
    static func render(title: String, subtitle: String, text: String, scale: CGFloat) -> UIImage? {
        let renderer = ImageRenderer(content: ShareCardView(
            title: title,
            subtitle: subtitle,
            text: text
        ))
        renderer.scale = scale
        return renderer.uiImage
    }
}

struct ShareCardView: View {
    let title: String
    let subtitle: String
    let text: String

    var body: some View {
        ZStack {
            AppBackground()
            AffirmationCard(title: title, subtitle: subtitle, text: text)
                .padding(24)
        }
        .frame(width: 720, height: 720)
    }
}
