import WidgetKit
import SwiftUI

struct WeatherWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Vær i \(entry.cityName.isEmpty ? "Ukjent" : entry.cityName)")
                .font(.headline)

            Divider()

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "thermometer")
                        Text("\(entry.temperature, specifier: "%.1f")°C")
                    }
                    HStack(spacing: 6) {
                        Image(systemName: "wind")
                        Text("\(entry.windSpeed, specifier: "%.1f") m/s")
                    }
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "cloud.rain")
                        Text("\(entry.precipitation, specifier: "%.1f") mm")
                    }
                    HStack(spacing: 6) {
                        Image(systemName: "sun.max")
                        Text("UV: \(entry.uvIndex, specifier: "%.1f")")
                    }
                }
            }
            .font(.footnote)
        }
        .padding()
        .background(Color(.systemBackground))
        .widgetURL(URL(string: "humi://open"))
    }
}

@main
struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Humi Widget")
        .description("Viser værdata: temp, vind, regn og UV.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
