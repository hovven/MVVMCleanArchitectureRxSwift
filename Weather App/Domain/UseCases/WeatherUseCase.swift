//
//  WeatherUseCase.swift
//  Weather App
//
//  Created by Hossein Vesali Naesh on 5/3/21.
//  Copyright © 2021 Kirtan Patel. All rights reserved.
//

import Foundation
import RxSwift

protocol WeatherUseCase {
    func execute() -> Completable
    func provideWeather(coordinate: Coordinate?) -> Single<WeatherModel>
    func provideHistoryData(coordinate: Coordinate?) -> Single<History>
    func provideSearchResults(cityName: String) -> Single<SearchResult>
}

final class DefaultWeatherUseCase : HasLocationService {
    
    let weatherRepository : WeatherRepository
    let locationService: LocationService
    
    private var coordinate : Coordinate!
    
    private let disposeBag = DisposeBag()
    
    init(weatherRepository: WeatherRepository, locationService: LocationService) {
        self.weatherRepository = weatherRepository
        self.locationService = locationService
    }
    
}

extension DefaultWeatherUseCase : WeatherUseCase {
    
    func execute() -> Completable {
        
        return Completable.create { [unowned self] completable in
            self.locationService.startUpdatingLocation()
            
            self.locationService.locationServiceError.subscribe(onNext: { [unowned self] error in
                if error != .NotAuthorized {
                    self.weatherRepository.setUserChosen()
                }
                completable(.error(error))
            }).disposed(by: disposeBag)
            
            self.locationService.coordinate.subscribe(onNext: {[weak self] coordinate in
                guard let self = self else { return }
                self.coordinate = coordinate
                completable(.completed)
            }).disposed(by: disposeBag)
            
            return Disposables.create {}
        }
    }
    
    func provideHistoryData(coordinate: Coordinate? = nil) -> Single<History> {
        return weatherRepository.fetchHistoryData(coordinate: coordinate == nil ? self.coordinate : coordinate!)
    }
    
    func provideWeather(coordinate: Coordinate? = nil) -> Single<WeatherModel> {
        return weatherRepository.fetchWeather(coordinate: coordinate == nil ? self.coordinate : coordinate!)
    }
    
    func provideSearchResults(cityName: String) -> Single<SearchResult> {
        return weatherRepository.fetchSearchResults(query: cityName)
    }
}
