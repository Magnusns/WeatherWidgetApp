import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: Date(), temperature: 0, windSpeed: 0, precipitation: 0, uvIndex: 0, cityName: "Oslo")
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> ()) {
        fetchWeather { entry in
            if let entry = entry {
                completion(entry)
            } else {
                completion(WeatherEntry(date: Date(), temperature: 0, windSpeed: 0, precipitation: 0, uvIndex: 0, cityName: "Oslo"))
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> ()) {
        fetchWeather { entry in
            let timelineEntry = entry ?? WeatherEntry(date: Date(), temperature: 0, windSpeed: 0, precipitation: 0, uvIndex: 0, cityName: "Oslo")
            let timeline = Timeline(entries: [timelineEntry], policy: .after(Date().addingTimeInterval(60 * 60)))
            completion(timeline)
        }
    }

    func fetchWeather(completion: @escaping (WeatherEntry?) -> ()) {
        let defaults = UserDefaults(suiteName: "group.humi.weather")
        let lat = defaults?.double(forKey: "selected_lat") ?? 59.91
        let lon = defaults?.double(forKey: "selected_lon") ?? 10.75
        let city = defaults?.string(forKey: "selected_city") ?? "Oslo"

        print("🌍 Widget loading weather for: \(city) at lat: \(lat), lon: \(lon)")

        guard let url = URL(string: "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=\(lat)&lon=\(lon)") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.setValue("HumiWidget/1.0 magnus@humi.no", forHTTPHeaderField: "User-Agent")

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                print("❌ Network error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            do {
                let met = try JSONDecoder().decode(MetResponse.self, from: data)
                if let details = met.properties.timeseries.first?.data.instant.details {
                    let entry = WeatherEntry(
                        date: Date(),
                        temperature: details.air_temperature ?? 0,
                        windSpeed: details.wind_speed ?? 0,
                        precipitation: details.precipitation_amount ?? 0,
                        uvIndex: details.ultraviolet_index_clear_sky ?? 0,
                        cityName: city
                    )
                    print("✅ Widget entry created: \(entry)")
                    completion(entry)
                } else {
                    print("❌ Missing details in API response")
                    completion(nil)
                }
            } catch {
                print("❌ Widget decoding failed: \(error)")
                if let json = String(data: data, encoding: .utf8) {
                    print("📦 Raw API response: \(json.prefix(300))...")
                }
                completion(nil)
            }
        }
        task.resume()
    }
}

