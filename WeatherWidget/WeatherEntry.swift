import WidgetKit
import SwiftUI

struct WeatherEntry: TimelineEntry {
    let date: Date
    let temperature: Double
    let windSpeed: Double
    let precipitation: Double
    let uvIndex: Double
    let cityName: String
}

