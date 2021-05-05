

import Foundation

// MARK: - WeatherModel
struct WeatherModel: Codable {
    let coord: Coord?
    let weather: [Weather]
    let base: String?
    let main: Main?
    let wind: Wind?
    let clouds: Clouds?
    let dt: Int?
    //let sys: Sys
    let timezone, id: Int?
    let name: String?
}

// MARK: - Clouds
struct Clouds: Codable {
    let all: Int?
}

// MARK: - Coord
struct Coord: Codable {
    let lon, lat: Double?
}

// MARK: - Main
struct Main: Codable {
    let temp, feelsLike, tempMin, tempMax: Double?
    let pressure, humidity: Int?

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
    }
}

//// MARK: - Sys
//struct Sys: Codable {
//    let id: Int
//    let country: String
//    let sunrise, sunset: Int
//}

// MARK: - Weather
struct Weather: Codable {
    let id: Int
    let main, weatherDescription, icon: String

    enum CodingKeys: String, CodingKey {
        case id, main
        case weatherDescription = "description"
        case icon
    }
}

// MARK: - Wind
struct Wind: Codable {
    let speed: Double
    let deg: Int
}


//public class WeatherModel : Decodable {
//    let coord : Coord
//    let weather : [currentWeatherModel]
//    let main: MainModel
//    let visibility: Double
//    let wind: Wind
//    let clouds: Clouds
//
//    public class MainModel: Decodable {
//        let temp: Double
//        let feelsLike: Double
//        let tempMin: Double
//        let tempMax: Double
//        let pressure: Double
//        let humidity: Double
//
//        enum CodingKeys: String, CodingKey {
//            case temp
//            case feelsLike = "feels_like"
//            case tempMin = "temp_min"
//            case tempMax = "temp_max"
//            case pressure
//            case humidity
//        }
//    }
//
//    public class Wind: Decodable {
//        let speed: Double
//        let deg: Double
//    }
//
//    public class Clouds: Decodable {
//        let all: Double
//    }
//
//    public class Coord: Decodable {
//        let latitude : Double
//        let longitude: Double
//
//        enum CodingKeys: String, CodingKey {
//            case latitude = "lat"
//            case longitude = "lon"
//        }
//    }
//
//    public class currentWeatherModel : Decodable {
//        let time : Date
//        let main : String
//        let icon : String
//        let description : String?
//    }
//}
