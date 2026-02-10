//
//  CardBackground.swift
//  Daily Affirmations
//
//  Created by Codex.
//

import SwiftUI

struct CardBackgroundModel {
    struct Blob {
        let center: CGPoint
        let radius: CGFloat
        let color: Color
        let opacity: Double
    }

    let baseColors: [Color]
    let blobs: [Blob]
}

enum CardBackgroundGenerator {
    static let baseColors: [Color] = [
        Color(red: 0.07, green: 0.10, blue: 0.24),
        Color(red: 0.12, green: 0.16, blue: 0.36),
        Color(red: 0.18, green: 0.18, blue: 0.42)
    ]

    static let palette: [Color] = [
        Color(red: 0.35, green: 0.60, blue: 0.95),
        Color(red: 0.58, green: 0.38, blue: 0.92),
        Color(red: 0.25, green: 0.45, blue: 0.88),
        Color(red: 0.40, green: 0.32, blue: 0.80)
    ]

    static let blobCountRange = 3...5
    static let radiusRange: ClosedRange<Double> = 140...320
    static let opacityRange: ClosedRange<Double> = 0.2...0.55
    static let centerXRange: ClosedRange<Double> = 0.15...0.85
    static let centerYRange: ClosedRange<Double> = 0.18...0.82

    static func make() -> CardBackgroundModel {
        var generator = SystemRandomNumberGenerator()
        return make(using: &generator)
    }

    static func make<T: RandomNumberGenerator>(using generator: inout T) -> CardBackgroundModel {
        let blobCount = Int.random(in: blobCountRange, using: &generator)
        let blobs = (0..<blobCount).map { _ in
            let center = CGPoint(
                x: Double.random(in: centerXRange, using: &generator),
                y: Double.random(in: centerYRange, using: &generator)
            )
            let radius = CGFloat(Double.random(in: radiusRange, using: &generator))
            let opacity = Double.random(in: opacityRange, using: &generator)
            let colorIndex = Int.random(in: 0..<palette.count, using: &generator)
            return CardBackgroundModel.Blob(
                center: center,
                radius: radius,
                color: palette[colorIndex],
                opacity: opacity
            )
        }

        return CardBackgroundModel(baseColors: baseColors, blobs: blobs)
    }
}

struct AffirmationCardBackgroundView: View {
    let model: CardBackgroundModel

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                LinearGradient(
                    colors: model.baseColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                ForEach(Array(model.blobs.enumerated()), id: \.offset) { _, blob in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    blob.color.opacity(blob.opacity),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: blob.radius
                            )
                        )
                        .frame(width: blob.radius * 2, height: blob.radius * 2)
                        .position(
                            x: size.width * blob.center.x,
                            y: size.height * blob.center.y
                        )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 26))
        }
    }
}
