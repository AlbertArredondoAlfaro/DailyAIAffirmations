//
//  BannerAdView.swift
//  Daily AI Affirmations
//
//  Created by Albert Bit Dj on 5/2/26.
//

import SwiftUI
import GoogleMobileAds
import UIKit

struct BannerAdContainer: View {
    let adUnitID: String

    var body: some View {
        HStack {
            Spacer(minLength: 0)
            BannerAdView(adUnitID: adUnitID)
                .frame(width: AdSizeBanner.size.width,
                       height: AdSizeBanner.size.height)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .accessibilityHidden(true)
    }
}

private struct BannerAdView: UIViewRepresentable {
    let adUnitID: String

    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = Self.findRootViewController()
        bannerView.load(Request())
        return bannerView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        if uiView.rootViewController == nil {
            uiView.rootViewController = Self.findRootViewController()
        }
    }

    private static func findRootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}
