import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(
            date: Date(),
            cityName: "Oslo",
            temperature: 0,
            conditionSymbol: "sun.max",
            hourlyForecast: []
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> ()) {
        fetchWeather { entry in
            if let entry = entry {
                completion(entry)
            } else {
                completion(WeatherEntry(
                    date: Date(),
                    cityName: "Oslo",
                    temperature: 0,
                    conditionSymbol: "sun.max",
                    hourlyForecast: []
                ))
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> ()) {
        fetchWeather { entry in
            let timelineEntry = entry ?? WeatherEntry(
                date: Date(),
                cityName: "Oslo",
                temperature: 0,
                conditionSymbol: "sun.max",
                hourlyForecast: []
            )
            let timeline = Timeline(entries: [timelineEntry], policy: .after(Date().addingTimeInterval(60 * 60)))
            completion(timeline)
        }
    }

    func fetchWeather(completion: @escaping (WeatherEntry?) -> ()) {
        let defaults = UserDefaults(suiteName: "group.humi.weather")
        let lat = defaults?.double(forKey: "selected_lat") ?? 59.91
        let lon = defaults?.double(forKey: "selected_lon") ?? 10.75
        let city = defaults?.string(forKey: "selected_city") ?? "Oslo"

        guard let url = URL(string: "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=\(lat)&lon=\(lon)") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.setValue("HumiWidget/1.0 magnus@humi.no", forHTTPHeaderField: "User-Agent")

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            do {
                let met = try JSONDecoder().decode(MetResponse.self, from: data)

                // Current Weather
                guard let firstTimeserie = met.properties.timeseries.first else {
                    completion(nil)
                    return
                }
                let current = firstTimeserie.data.instant.details

                // First 5 hours forecast
                let now = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "ha" // Example: 4PM, 5PM, etc.

                let firstFiveHours = met.properties.timeseries.prefix(5)
                let hourlyForecast = firstFiveHours.compactMap { timeserie -> HourlyForecast? in
                    guard let date = ISO8601DateFormatter().date(from: timeserie.time) else { return nil }
                    let details = timeserie.data.instant.details
                    return HourlyForecast(
                        hour: formatter.string(from: date),
                        symbol: "cloud.sun", // 🌟 Improve soon
                        temperature: Int(details.air_temperature ?? 0)
                    )
                }

                let entry = WeatherEntry(
                    date: now,
                    cityName: city,
                    temperature: current.air_temperature ?? 0,
                    conditionSymbol: "sun.max", // 🌟 Improve soon
                    hourlyForecast: hourlyForecast
                )

                completion(entry)

            } catch {
                print("❌ Decoding error: \(error.localizedDescription)")
                completion(nil)
            }
        }
        task.resume()
    }
}

