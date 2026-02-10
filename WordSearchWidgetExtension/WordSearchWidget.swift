//
//  WordSearchWidget.swift
//  WordSearchWidgetExtension
//

import WidgetKit
import SwiftUI
import Foundation
import Core

@available(iOS 17.0, *)
struct WordSearchProvider: TimelineProvider {
    typealias Entry = WordSearchEntry

    func placeholder(in context: Context) -> WordSearchEntry {
        WordSearchEntry(date: Date(), state: WordSearchPersistence.loadState(at: Date()))
    }

    func getSnapshot(in context: Context, completion: @escaping (WordSearchEntry) -> Void) {
        let state = WordSearchPersistence.loadState(at: Date())
        completion(WordSearchEntry(date: Date(), state: state))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WordSearchEntry>) -> Void) {
        let now = Date()
        let state = WordSearchPersistence.loadState(at: now)
        let entry = WordSearchEntry(date: now, state: state)
        let refreshAt = WordSearchPersistence.nextRefreshDate(from: now, state: state)
        completion(Timeline(entries: [entry], policy: .after(refreshAt)))
    }
}

@available(iOS 17.0, *)
struct WordSearchEntry: TimelineEntry {
    let date: Date
    let state: WordSearchState
}

@available(iOS 17.0, *)
struct WordSearchWidget: Widget {
    let kind: String = WordSearchConstants.widgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WordSearchProvider()) { entry in
            WordSearchWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(WidgetStrings.configurationDisplayName)
        .description(WidgetStrings.configurationDescription)
        .supportedFamilies([.systemLarge])
        .contentMarginsDisabled()
    }
}
