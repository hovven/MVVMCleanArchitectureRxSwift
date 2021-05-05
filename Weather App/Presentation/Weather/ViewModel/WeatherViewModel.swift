//
//  WeatherViewModel.swift
//  Weather App
//
//  Created by Hossein Vesali Naesh on 5/1/21.
//  Copyright © 2021 Kirtan Patel. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFlow

protocol WeatherViewModelInput : ViewModelInput {
    func didSearchCity(with cityName: String)
    func feedTableView(coordinate: Coordinate?)
}

protocol WeatherViewModelOutput {
    var tempreture : BehaviorRelay<String> { get }
    var cityName : BehaviorRelay<String> { get }
    var cities : PublishSubject<[WeatherModel]> { get }
    var historyItems : PublishSubject<[Current]> { get }
    var weatherDescription : BehaviorRelay<String> { get }
    var lowHighTemp : BehaviorRelay<String> { get }
    var error : PublishSubject<String> { get }
}

final class WeatherViewModel: ServicesViewModel, Stepper, WeatherViewModelInput, WeatherViewModelOutput {
    
    typealias UseCase = WeatherUseCase
    var usecas: WeatherUseCase!
    
    let steps = PublishRelay<Step>()
    
    var tempreture: BehaviorRelay<String> = BehaviorRelay(value: "0°")
    var cityName: BehaviorRelay<String> = BehaviorRelay(value: "Loading...")
    var weatherDescription: BehaviorRelay<String> = BehaviorRelay(value: "Loading...")
    var lowHighTemp : BehaviorRelay<String> = BehaviorRelay(value: "0° / 0°")
    var cities: PublishSubject<[WeatherModel]> = PublishSubject<[WeatherModel]>()
    var historyItems: PublishSubject<[Current]> = PublishSubject<[Current]>()
    var error: PublishSubject<String> = PublishSubject()
    
    private let disposeBag = DisposeBag()
    
    func viewDidLoad() {
        usecas.execute().subscribe { [weak self] in
            guard let self = self else { return }
            self.feedTableView()
        } onError: { [weak self] (error) in
            guard let self = self else { return }
            self.resolve(locationServiceError: error as! LocationServiceError)
        }.disposed(by: disposeBag)
        
    }
    
    private func provideWeatherData(coordinate: Coordinate?) {
        self.usecas.provideWeather(coordinate: coordinate).subscribe(onSuccess: { [weak self] (weatherModel) in
            guard let self = self else { return }
            self.configureOutput(weather: weatherModel)
        }, onError: { [weak self] (error) in
            guard let self = self else {return}
            if let networkError = error as? NetworkError {
                self.resolve(networkError: networkError)
            } else {
                self.resolve(error: error as! QueryResponseError)
            }
        }).disposed(by: disposeBag)
        
    }
    
    private func provideHistoryData(coordinate: Coordinate?) {
        usecas.provideHistoryData(coordinate: coordinate).subscribe(onSuccess: { [weak self] (history) in
            guard let self = self else { return }
            self.configureOutput(history: history)
        }, onError: { [weak self] (error) in
            guard let self = self else {return}
            if let networkError = error as? NetworkError {
                self.resolve(networkError: networkError)
            } else {
                self.resolve(error: error as! QueryResponseError)
            }
        }).disposed(by: disposeBag)
    }
    
    func feedTableView(coordinate: Coordinate? = nil) {
        self.provideWeatherData(coordinate: coordinate)
        self.provideHistoryData(coordinate: coordinate)
    }
    
    func didSearchCity(with cityName: String) {
        usecas.provideSearchResults(cityName: cityName).subscribe { [weak self] (searchResult) in
            guard let self = self else { return }
            self.configureOutput(result: searchResult)
        } onError: { [weak self] (error) in
            guard let self = self else {return}
            if let networkError = error as? NetworkError {
                self.resolve(networkError: networkError)
            }
        }.disposed(by: disposeBag)
        
    }
    
    private func configureOutput(weather: WeatherModel) {
        tempreture.accept(String(format: "%.0f°", toCelsius(kelvin: weather.main?.temp ?? 0)))
        cityName.accept(weather.name ?? String())
        weatherDescription.accept(weather.weather.first?.weatherDescription ?? String())
        lowHighTemp.accept(String(format: "%.0f°", toCelsius(kelvin: weather.main?.tempMin ?? 0)) + " / " + String(format: "%.0f°", toCelsius(kelvin: weather.main?.tempMax ?? 0)))
    }
    
    private func configureOutput(result: SearchResult) {
        cities.onNext(result.list)
    }
    
    private func configureOutput(history: History) {
        historyItems.onNext(history.hourly)
    }
    
    func toCelsius(kelvin: Double) -> Double {
        return kelvin - 273.15
    }
    
    private func resolve(error: QueryResponseError) {
        switch error {
        case .NotFound:
            self.error.onNext(NSLocalizedString("There is no recorded data please connect to internet to get results!", comment: ""))
        }
    }
    
    private func resolve(networkError: NetworkError) {
        switch networkError {
        case .notConnected:
            self.error.onNext(NSLocalizedString("please connect your device to internet", comment: ""))
        case .error(let statusCode, _):
            self.error.onNext(NSLocalizedString("request failed with status code \(statusCode)", comment: ""))
        case .generic(let err):
            print(err)
            self.error.onNext(NSLocalizedString("request failed with error \(err)", comment: ""))
        default: break
        }
    }
    
    private func resolve(locationServiceError: LocationServiceError) {
        switch locationServiceError {
        case .LocationDisabled:
            self.error.onNext(NSLocalizedString("please enable location access in your settings", comment: ""))
        case .LocationServicesOff:
            self.error.onNext(NSLocalizedString("please enable location services in your settings", comment: ""))
        case .NotAuthorized:
            break
        }
    }
}

