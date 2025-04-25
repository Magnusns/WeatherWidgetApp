import Foundation

struct MetResponse: Codable {
    struct Properties: Codable {
        struct Timeseries: Codable {
            let time: String
            struct DataClass: Codable {
                struct Instant: Codable {
                    struct Details: Codable {
                        let air_temperature: Double?
                        let wind_speed: Double?
                        let precipitation_amount: Double?
                        let ultraviolet_index_clear_sky: Double?

                        enum CodingKeys: String, CodingKey {
                            case air_temperature
                            case wind_speed
                            case precipitation_amount = "precipitation_amount"
                            case ultraviolet_index_clear_sky = "ultraviolet_index_clear_sky"
                        }
                    }
                    let details: Details
                }
                let instant: Instant
            }
            let data: DataClass
        }
        let timeseries: [Timeseries]
    }
    let properties: Properties
}

