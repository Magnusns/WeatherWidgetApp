import WidgetKit
import SwiftUI

struct WeatherWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            // Full background
            LinearGradient(
                colors: [Color.blue.opacity(0.9), Color.blue.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea() // <-- THIS is what was missing!

            // Actual content
            VStack(alignment: .leading, spacing: 8) {
                // Top section
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.cityName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        Text("\(Int(entry.temperature))°")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Image(systemName: entry.conditionSymbol)
                        .font(.system(size: 36))
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal)

                Spacer()

                // Forecast
                HStack(spacing: 12) {
                    ForEach(entry.hourlyForecast.prefix(5)) { forecast in
                        VStack(spacing: 4) {
                            Text(forecast.hour)
                                .font(.caption2)
                                .foregroundColor(.white)
                            Image(systemName: forecast.symbol)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                            Text("\(forecast.temperature)°")
                                .font(.caption2)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
            .padding(.vertical, 8)
        }
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
        .description("Viser temperatur og time for time.")
        .supportedFamilies([.systemMedium])
    }
}

