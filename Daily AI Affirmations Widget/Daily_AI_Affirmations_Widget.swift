//
//  Daily_AI_Affirmations_Widget.swift
//  Daily AI Affirmations Widget
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
            language: language
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (AffirmationEntry) -> Void) {
        let language = AffirmationSelector.language(for: .current)
        let affirmation = AffirmationSelector.dailyAffirmation(for: .now, language: language, allowPlaceholders: false)
        completion(AffirmationEntry(date: .now, affirmation: affirmation, language: language))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AffirmationEntry>) -> Void) {
        let language = AffirmationSelector.language(for: .current)
        let now = Date()
        let affirmation = AffirmationSelector.dailyAffirmation(for: now, language: language, allowPlaceholders: false)
        let entry = AffirmationEntry(date: now, affirmation: affirmation, language: language)

        let calendar = Calendar.current
        let startOfTomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now) ?? now)
        let timeline = Timeline(entries: [entry], policy: .after(startOfTomorrow))
        completion(timeline)
    }
}

struct AffirmationEntry: TimelineEntry {
    let date: Date
    let affirmation: String
    let language: AffirmationLanguage
}

struct Daily_AI_Affirmations_WidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: Provider.Entry

    var body: some View {
        content
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .systemSmall:
            smallBody
        case .systemMedium:
            mediumBody
        case .accessoryRectangular:
            rectangularBody
        case .accessoryCircular:
            circularBody
        case .accessoryInline:
            inlineBody
        default:
            smallBody
        }
    }

    private var smallBody: some View {
        card
    }

    private var mediumBody: some View {
        card
    }

    private var rectangularBody: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(WidgetStrings.shortTitle(for: entry.language))
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text(entry.affirmation)
                .font(.caption)
                .lineLimit(2)
        }
    }

    private var circularBody: some View {
        ZStack {
            Circle().fill(.clear)
            Text("AI")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
        }
    }

    private var inlineBody: some View {
        Text(entry.affirmation)
            .font(.caption2)
            .lineLimit(1)
    }

    private var card: some View {
        return VStack(alignment: .leading, spacing: 8) {
            Text(WidgetStrings.title(for: entry.language))
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))

            Text(entry.affirmation)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 18))
    }
}

struct Daily_AI_Affirmations_Widget: Widget {
    let kind: String = "Daily_AI_Affirmations_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Daily_AI_Affirmations_WidgetEntryView(entry: entry)
                .widgetBackground()
        }
        .configurationDisplayName("Daily AI Affirmations")
        .description(NSLocalizedString("widget_description", comment: ""))
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryInline,
            .accessoryCircular,
            .accessoryRectangular
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

#Preview(as: .systemSmall) {
    Daily_AI_Affirmations_Widget()
} timeline: {
    AffirmationEntry(date: .now, affirmation: "Hoy elijo la calma y la claridad.", language: .spanish)
    AffirmationEntry(date: .now, affirmation: "Today I choose calm and clarity.", language: .english)
}
