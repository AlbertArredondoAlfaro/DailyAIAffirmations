//
//  AffirmationCard.swift
//  Daily Affirmations
//
//  Created by Codex.
//

import SwiftUI

struct AffirmationCard: View {
    let title: String
    let subtitle: String
    let text: String
    let detailText: String
    let illustrationName: String
    let background: CardBackgroundModel

    var body: some View {
        cardContent
            .glassCard(cornerRadius: 26)
    }

    private var cardContent: some View {
        ZStack {
            AffirmationCardBackgroundView(model: background)

            RoundedRectangle(cornerRadius: 26)
                .fill(Color.black.opacity(0.28))

            VStack(alignment: .leading, spacing: 2) {
                Image(illustrationName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 128)
                    .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
                    .padding(.top, 12)
                    .frame(maxWidth: .infinity)
                    .accessibilityHidden(true)

                Spacer(minLength: 2)

                VStack(spacing: 6) {
                    Text(text)
                        .font(.system(size: 26, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.98))
                        .lineSpacing(4)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 3)

                    Text(detailText)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                Spacer(minLength: 0)
            }
            .padding(22)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.top, -30)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(subtitle). \(text)"))
    }
}
