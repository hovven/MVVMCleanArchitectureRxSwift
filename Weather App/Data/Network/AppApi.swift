//
//  AppApi.swift
//  Weather App
//
//  Created by Hossein Vesali Naesh on 5/1/21.
//  Copyright © 2021 Hoven. All rights reserved.
//

import Moya

enum AppApi {
    case fetchWeather(coordinate: Coordinate)
    case search(query: String)
    case historyData(coordinate: Coordinate)
}

extension AppApi : TargetType {
    
    var baseURL: URL {
        switch self {
        case .fetchWeather(let coordinate):
            return URL(string: "https://community-open-weather-map.p.rapidapi.com/weather?&lat=\(coordinate.latitude)&lon=\(coordinate.longitude)")!
        case .search(let query):
            return URL(string: "https://community-open-weather-map.p.rapidapi.com/find?q=\(query)&cnt=10")!
        case .historyData(let coordinate):
            return URL(string: "https://community-open-weather-map.p.rapidapi.com/onecall/timemachine?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&dt=\(Int(NSDate().timeIntervalSince1970))")!
        }
        
    }
    
    var path: String {
        return ""
    }
    
    var method: Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        return ["x-rapidapi-host":"community-open-weather-map.p.rapidapi.com"]
    }
    
    
}
