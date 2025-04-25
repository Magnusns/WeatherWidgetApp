//
//  LocationManager.swift
//  WeatherWidgetApp
//
//  Created by Magnus Nilsen Sødergren on 25/04/2025.
//

import Foundation
import WidgetKit

class LocationManager {
    static let shared = LocationManager()

    private let appGroupID = "group.humi.weather"

    func save(lat: Double, lon: Double, cityName: String) {
        if let defaults = UserDefaults(suiteName: appGroupID) {
            defaults.set(lat, forKey: "selected_lat")
            defaults.set(lon, forKey: "selected_lon")
            defaults.set(cityName, forKey: "selected_city")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    func getSavedLocation() -> (lat: Double, lon: Double)? {
        if let defaults = UserDefaults(suiteName: appGroupID),
           let lat = defaults.value(forKey: "selected_lat") as? Double,
           let lon = defaults.value(forKey: "selected_lon") as? Double {
            return (lat, lon)
        }
        return nil
    }
}
