//
//  Daily_Affirmations_Widget.swift
//  Daily Affirmations Widget
//
//  Created by Albert Bit Dj on 5/2/26.
//

import WidgetKit
import SwiftUI

private enum WidgetStrings {
    static func title(for language: AffirmationLanguage) -> String {
        NSLocalizedString("widget_title", comment: "")
    }

    static func shortTitle(for language: AffirmationLanguage) -> String {
        NSLocalizedString("widget_short_title", comment: "")
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> AffirmationEntry {
        let language = AffirmationSelector.language(for: .current)
        return AffirmationEntry(
            date: .now,
            affirmation: AffirmationSelector.catalog(for: language, allowPlaceholders: false).first ?? "",
            detail: AffirmationExpansionGenerator.expand(
                affirmation: AffirmationSelector.catalog(for: language, allowPlaceholders: false).first ?? "",
                language: language
            ),
            language: language
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (AffirmationEntry) -> Void) {
        let language = AffirmationSelector.language(for: .current)
        let affirmation = AffirmationSelector.dailyAffirmation(for: .now, language: language, allowPlaceholders: false)
        let detail = AffirmationExpansionGenerator.expand(affirmation: affirmation, language: language)
        completion(AffirmationEntry(date: .now, affirmation: affirmation, detail: detail, language: language))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AffirmationEntry>) -> Void) {
        let language = AffirmationSelector.language(for: .current)
        let now = Date()
        let affirmation = AffirmationSelector.dailyAffirmation(for: now, language: language, allowPlaceholders: false)
        let detail = AffirmationExpansionGenerator.expand(affirmation: affirmation, language: language)
        let entry = AffirmationEntry(date: now, affirmation: affirmation, detail: detail, language: language)

        let nextRefresh = WidgetTimelineHelper.nextRefreshDate(from: now)
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        completion(timeline)
    }
}

struct AffirmationEntry: TimelineEntry {
    let date: Date
    let affirmation: String
    let detail: String
    let language: AffirmationLanguage
}

struct Daily_Affirmations_WidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: Provider.Entry

    var body: some View {
        content
    }

    @ViewBuilder
    private var content: some View {
        card
    }

    private var card: some View {
        return VStack(alignment: .leading, spacing: 10) {
            Text(WidgetStrings.title(for: entry.language))
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))

            Text(entry.affirmation)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(5)

            Text(entry.detail)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.75))
                .lineLimit(6)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 18))
    }
}

struct Daily_Affirmations_Widget: Widget {
    let kind: String = "Daily_Affirmations_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Daily_Affirmations_WidgetEntryView(entry: entry)
                .widgetBackground()
        }
        .configurationDisplayName("My Daily Affirmations")
        .description(NSLocalizedString("widget_description", comment: ""))
        .supportedFamilies([
            .systemMedium,
            .systemLarge
        ])
    }
}

private extension View {
    @ViewBuilder
    func widgetBackground() -> some View {
        if #available(iOS 17.0, *) {
            self.containerBackground(for: .widget) {
                LinearGradient(
                    colors: [
                        Color(red: 0.07, green: 0.10, blue: 0.24),
                        Color(red: 0.12, green: 0.16, blue: 0.36),
                        Color(red: 0.18, green: 0.18, blue: 0.42)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        } else {
            self.background()
        }
    }

    @ViewBuilder
    func glassCard(cornerRadius: CGFloat) -> some View {
        if #available(iOS 26, *) {
            self
                .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            self
                .background(.ultraThinMaterial, in: .rect(cornerRadius: cornerRadius))
        }
    }
}

#Preview(as: .systemLarge) {
    Daily_Affirmations_Widget()
} timeline: {
    AffirmationEntry(
        date: .now,
        affirmation: "Hoy elijo la calma y la claridad.",
        detail: "Regálate una respiración tranquila y un ritmo amable. Incluso los pasos pequeños son progreso.",
        language: .spanish
    )
    AffirmationEntry(
        date: .now,
        affirmation: "Today I choose calm and clarity.",
        detail: "Give yourself a steady breath and a kind pace. Even small steps are meaningful progress.",
        language: .english
    )
}
