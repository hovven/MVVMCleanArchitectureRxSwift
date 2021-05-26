//
//  AppDIContainer.swift
//  Weather App
//
//  Created by Hossein Vesali Naesh on 5/2/21.
//  Copyright © 2021 Kirtan Patel. All rights reserved.
//

import Foundation

final class AppDIContainer: HasPreferencesService, HasNetworkService, HasLocationService {
    
    let preferencesService = PreferencesService()
    lazy var appConfiguration = AppConfiguration()
    
    lazy var networkService : NetworkService = {
        let config = ApiDataNetworkConfig(headers: ["x-rapidapi-key":appConfiguration.apiKey])
        return DefaultNetworkService(config: config)
    }()
    
    lazy var locationService : LocationService = {
        return DefaultLocationService(preferencesService: self.preferencesService)
    }()
    
    func makeWeatherDIContainer() -> WeatherDIContainer {
        return WeatherDIContainer(networkService: networkService, locationService: locationService, preferencesService: preferencesService)
    }
    
    
}
