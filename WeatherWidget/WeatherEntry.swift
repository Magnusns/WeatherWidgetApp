import WidgetKit
import SwiftUI

struct WeatherEntry: TimelineEntry {
    let date: Date
    let cityName: String
    let temperature: Double
    let conditionSymbol: String
    let hourlyForecast: [HourlyForecast]
}

struct HourlyForecast: Identifiable {
    let id = UUID()
    let hour: String   // like "4PM"
    let symbol: String // like "sun.max"
    let temperature: Int
}
