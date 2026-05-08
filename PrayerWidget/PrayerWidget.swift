import WidgetKit
import SwiftUI
import UIKit

struct PrayerEntry: TimelineEntry {
    let date: Date
}

struct PrayerWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> PrayerEntry {
        PrayerEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> Void) {
        completion(PrayerEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerEntry>) -> Void) {
        completion(Timeline(entries: [PrayerEntry(date: Date())], policy: .never))
    }
}

// MARK: - Shared widget view

struct PrayerWidgetView: View {
    @Environment(\.widgetFamily) var family
    let imageName: String
    let imageExtension: String

    var body: some View {
        ZStack {
            if family != .systemSmall {
                Color.black.opacity(0.35)
                Text("Begin Prayer")
                    .font(.subheadline)
                    .fontWeight(.light)
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
        .containerBackground(for: .widget) {
            if let path = Bundle.main.path(forResource: imageName, ofType: imageExtension),
               let uiImage = UIImage(contentsOfFile: path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            }
        }
        .widgetURL(URL(string: "prayerapp://start"))
    }
}

// MARK: - Three widget variants

struct PrayerWidget: Widget {
    let kind: String = "PrayerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerWidgetProvider()) { _ in
            PrayerWidgetView(imageName: "dove", imageExtension: "jpeg")
        }
        .configurationDisplayName("Prayer — Blue")
        .description("Tap to begin your prayer session.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct PrayerWidget2: Widget {
    let kind: String = "PrayerWidget2"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerWidgetProvider()) { _ in
            PrayerWidgetView(imageName: "dove2", imageExtension: "png")
        }
        .configurationDisplayName("Prayer — Golden")
        .description("Tap to begin your prayer session.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct PrayerWidget3: Widget {
    let kind: String = "PrayerWidget3"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerWidgetProvider()) { _ in
            PrayerWidgetView(imageName: "dove3", imageExtension: "png")
        }
        .configurationDisplayName("Prayer — Warm")
        .description("Tap to begin your prayer session.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
