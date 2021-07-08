//
//  widgets.swift
//  widgets
//
//  Created by donghyun on 2021/06/04.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), data: nil)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        NetworkForecaseUseCase().requestForecast(at: Date(), completion: { result in
            switch result {
            case let .success(data):
                let entry = SimpleEntry(date: Date(), configuration: configuration, data: data)
                completion(entry)
            case let .failure(error):
                let entry = SimpleEntry(date: Date(), configuration: configuration, data: nil)
                completion(entry)
            }
        })
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        NetworkForecaseUseCase().requestForecast(at: Date(), completion: { result in
            let entryDate = Calendar.current.date(byAdding: .minute, value: 40, to: Date())!
            
            switch result {
            case let .success(data):
                let entry = SimpleEntry(date: entryDate, configuration: configuration, data: data)
                entries.append(entry)
            case .failure:
                let entry = SimpleEntry(date: entryDate, configuration: configuration, data: nil)
                entries.append(entry)
            }
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        })
    }
}

extension Double{
    func asTemperature() -> String {
        return floor(self) == self ? "\(Int(self))" : "\(self)"
    }
}

extension Sky {
    var image: Image {
        switch self {
        case .sunny:
            return Image("clear")
        case .cloudy:
            return Image("cloudy")
        case .rainy:
            return Image("rain")
        case .snow:
            return Image("snow")
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let data: ForecastData?
}

struct widgetsEntryView : View {
    var entry: Provider.Entry

    var temperature: String {
        guard let value = entry.data?.temperature.current else {
            return "--"
        }
        return value.asTemperature()
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            entry.data!.sky.image.resizable().frame(width: 64, height: 64)
            
            
            Spacer().frame(height: 10)
            
            HStack {
                Spacer().frame(width: 19)
                Text(temperature).font(.title).fontWeight(.medium)
                Spacer().frame(width: 0)
                Text("℃").fontWeight(.bold).padding(.bottom, 10)
            }
            
            Spacer()
        }
    }
}

@main
struct widgets: Widget {
    let kind: String = "widgets"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            widgetsEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct widgets_Previews: PreviewProvider {
    static var previews: some View {
        let data = ForecastData(temperature: DayTemperature(current: 10, low: 0, high: 0), sky: .sunny)
        widgetsEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), data: data))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
