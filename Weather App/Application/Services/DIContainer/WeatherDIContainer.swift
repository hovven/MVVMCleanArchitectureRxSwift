//
//  WeatherDIContainer.swift
//  Weather App
//
//  Created by Hossein Vesali Naesh on 5/3/21.
//  Copyright © 2021 Kirtan Patel. All rights reserved.
//

import Foundation

final class WeatherDIContainer {
    
    private var networkService: NetworkService
    private var preferencesService: PreferencesService
    private var locationService: LocationService
    
    init(networkService: NetworkService, locationService: LocationService, preferencesService: PreferencesService) {
        self.networkService = networkService
        self.locationService = locationService
        self.preferencesService = preferencesService
    }
    
    func makeWeatherUseCase() -> DefaultWeatherUseCase {
        return DefaultWeatherUseCase(weatherRepository: self.weatherRepository, locationService: self.locationService)
    }
    
    // MARK: - Use Cases
//    lazy var weatherUseCase : DefaultWeatherUseCase = {
//        return DefaultWeatherUseCase(weatherRepository: self.weatherRepository, locationService: self.locationService)
//    }()
    
    // MARK: - Repositories
    private lazy var weatherRepository = {
        return DefaultWeatherRepository(networkService: self.networkService, preferencesService: self.preferencesService)
    }()
    
}
