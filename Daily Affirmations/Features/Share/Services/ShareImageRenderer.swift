//
//  ShareImageRenderer.swift
//  Daily Affirmations
//
//  Created by Codex.
//

import SwiftUI

@MainActor
struct ShareImageRenderer {
    static func render(
        title: String,
        subtitle: String,
        text: String,
        detailText: String,
        illustrationName: String,
        scale: CGFloat
    ) -> UIImage? {
        let view = ShareStoryView(
            title: title,
            subtitle: subtitle,
            text: text,
            detailText: detailText,
            illustrationName: illustrationName
        )
        let renderer = ImageRenderer(content: view)
        renderer.proposedSize = .init(width: 1080, height: 1920)
        renderer.scale = max(scale, 1)
        if let image = renderer.uiImage {
            return image
        }

        return fallbackRender(view: view)
    }

    private static func fallbackRender(view: ShareStoryView) -> UIImage? {
        let size = CGSize(width: 1080, height: 1920)
        let controller = UIHostingController(rootView: view)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

struct ShareStoryView: View {
    let title: String
    let subtitle: String
    let text: String
    let detailText: String
    let illustrationName: String

    private var illustration: UIImage? {
        UIImage(named: illustrationName)
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 12) {
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

                if let illustration {
                    Image(uiImage: illustration)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 480)
                        .shadow(color: .black.opacity(0.25), radius: 14, x: 0, y: 8)
                        .padding(.top, 12)
                        .padding(.bottom, -6)
                }

                Text(text)
                    .font(.system(size: 76, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 80)

                Text(detailText)
                    .font(.system(size: 46, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.78))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 110)

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
        text: "Respira paz, exhala tranquilidad.",
        detailText: "Regálate una respiración tranquila y un ritmo amable. Incluso los pasos pequeños son progreso.",
        illustrationName: "AffirmationIllustration01"
    )
}
