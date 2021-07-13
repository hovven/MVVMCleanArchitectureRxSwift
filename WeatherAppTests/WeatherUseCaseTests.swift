//
//  WeatherAppTests.swift
//  WeatherAppTests
//
//  Created by Hossein Vesali Naesh on 5/4/21.
//  Copyright © 2021 Hoven. All rights reserved.
//

import XCTest
import RxSwift

class WeatherUseCaseTests: XCTestCase {

    static let searchResult = SearchResult(count: 14, list: [weatherModel])
    static let coordinate = Coordinate(latitude: 51.5085, longitude: 36.4532)
    static let current = Current(dt: 12345, sunrise: 12, sunset: 32, temp: 280, feelsLike: 285, pressure: 10, humidity: 23, dewPoint: 35, uvi: 76, clouds: 35, visibility: 0, windSpeed: 10, windDeg: 45, weather: weathers)
    static let weathers = [Weather(id: 1, main: "Tehran", weatherDescription: "cloudy", icon: "")]
    static let weatherModel = WeatherModel(coord: Coord(lon: 51.5085, lat: 36.4532), weather: weathers, base: "", main: Main(temp: 290, feelsLike: 230, tempMin: 280, tempMax: 300, pressure: 10, humidity: 10), wind: Wind(speed: 12, deg: 34), clouds: Clouds(all: 30), dt: 12345, timezone: 54321, id: 12343, name: "Tehran")
    
    
    struct WeatherRepositoryMock: WeatherRepository {
        
        func fetchWeather(coordinate: Coordinate) -> Single<WeatherModel> {
            return Single<WeatherModel>.create { single in
                single(.success(weatherModel))
                return Disposables.create { }
            }
        }
        
        let history = History(lat: 51.5085, lon: 36.4532, timezone: "", timezoneOffset: 10, current: current, hourly: [current])
        
        func fetchHistoryData(coordinate: Coordinate) -> Single<History> {
            return Single<History>.create { single in
                single(.success(history))
                return Disposables.create { }
            }
        }
        
        
        func fetchSearchResults(query: String) -> Single<SearchResult> {
            return Single<SearchResult>.create { single in
                single(.success(searchResult))
                return Disposables.create { }
            }
        }
        
        func setUserChosen() {
            
        }
    }
    
    struct PreferencesServiceMock : WeatherResponseStorage, LocationServiceResponseStorage {
        
        func getResponse<T: Codable>(requestDTO: T.Type, forKey key: String) -> Result<T, QueryResponseError> {
            if let object = self.get(requestDTO: requestDTO, key: key) {
                return .success(object)
            }else{
                return .failure(QueryResponseError.NotFound)
            }
        }
        
        private func get<T:Codable>(requestDTO: T.Type, key: String) -> T? {
            return searchResult as? T
        }
        
        func save<T: Codable>(requestDTO: T, key: String) {
            
        }
        
        func setHasChosen() {
            
        }
        
        func setNotChosen() {
            
        }
        
        func hasChosen() -> Bool {
            return true
        }
        
    }
    
    struct LocationServiceMock : LocationService {
        var coordinate: PublishSubject<Coordinate> = PublishSubject()
        var locationServiceError: PublishSubject<LocationServiceError> = PublishSubject()
        
        func startUpdatingLocation() {
            coordinate.onNext(WeatherUseCaseTests.coordinate)
        }
        
    }
    
    func testWeatherUseCase_whenSuccessfullyFetchesWeatherData_thenDataIsSavedInUserDefaults() {
        // given
        let expectation = self.expectation(description: "Recent weather saved")
        expectation.expectedFulfillmentCount = 3
        let weatherRepository = WeatherRepositoryMock()
        let locationService = LocationServiceMock()
        
        let useCase = DefaultWeatherUseCase(weatherRepository: weatherRepository, locationService: locationService)
        
        // when
        _ = useCase.provideHistoryData(coordinate: WeatherUseCaseTests.coordinate).subscribe { (history) in
            expectation.fulfill()
        } onError: { (error) in
            
        }
        
        _ = useCase.provideWeather(coordinate: WeatherUseCaseTests.coordinate).subscribe { (history) in
            expectation.fulfill()
        } onError: { (error) in
        
        }
        
        // then
        
        _ = weatherRepository.fetchHistoryData(coordinate: WeatherUseCaseTests.coordinate).subscribe { (history) in
            expectation.fulfill()
        } onError: { (error) in
            
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
}
