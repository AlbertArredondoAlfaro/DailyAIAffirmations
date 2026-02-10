//
//  BannerAdView.swift
//  Daily Affirmations
//
//  Created by Albert Bit Dj on 5/2/26.
//

import SwiftUI
import GoogleMobileAds
import UIKit

struct BannerAdContainer: View {
    let adUnitID: String
    @StateObject private var trackingManager = TrackingAuthorizationManager.shared

    var body: some View {
        Group {
            if trackingManager.canRequestAds {
                HStack {
                    Spacer(minLength: 0)
                    BannerAdView(
                        adUnitID: adUnitID,
                        isPersonalizedAllowed: trackingManager.isPersonalizedAdsAllowed
                    )
                    .frame(width: AdSizeBanner.size.width,
                           height: AdSizeBanner.size.height)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)
            }
        }
    }
}

private struct BannerAdView: UIViewRepresentable {
    let adUnitID: String
    let isPersonalizedAllowed: Bool

    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = Self.findRootViewController()
        bannerView.load(AdRequestFactory.make(isPersonalizedAllowed: isPersonalizedAllowed))
        context.coordinator.lastIsPersonalizedAllowed = isPersonalizedAllowed
        return bannerView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        if uiView.rootViewController == nil {
            uiView.rootViewController = Self.findRootViewController()
        }
        if context.coordinator.lastIsPersonalizedAllowed != isPersonalizedAllowed {
            context.coordinator.lastIsPersonalizedAllowed = isPersonalizedAllowed
            uiView.load(AdRequestFactory.make(isPersonalizedAllowed: isPersonalizedAllowed))
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    private static func findRootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }

    final class Coordinator {
        var lastIsPersonalizedAllowed: Bool?
    }
}
