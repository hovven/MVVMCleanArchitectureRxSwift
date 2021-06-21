//
//  DefaultWeatherRepository.swift
//  Weather App
//
//  Created by Hossein Vesali Naesh on 5/3/21.
//  Copyright © 2021 Kirtan Patel. All rights reserved.
//

import Foundation
import RxSwift
import Moya

final class DefaultWeatherRepository {
    
    let networkService: NetworkService
    let preferencesService: PreferencesService
    
    private let disposeBag = DisposeBag()
    
    init(networkService: NetworkService, preferencesService: PreferencesService) {
        self.networkService = networkService
        self.preferencesService = preferencesService
    }
}

extension DefaultWeatherRepository : WeatherRepository {
    
    func fetchSearchResults(query: String) -> Single<SearchResult> {
        return Single.create { [unowned self] singel in
            self.networkService.request(targetApi: AppApi.search(query: query), responseModel: SearchResult.self).subscribe { (searchResult) in
                if let result = searchResult {
                    singel(.success(result))
                }
            } onError: { (error) in
                singel(.error(error))
            }.disposed(by: disposeBag)
            
            return Disposables.create {}
        }
    }
    
    func fetchHistoryData(coordinate: Coordinate) -> Single<History> {
        return Single<History>.create { [unowned self] single in
            
            self.networkService.request(targetApi: AppApi.historyData(coordinate: coordinate), responseModel: History.self).subscribe { [unowned self]  (response) in
                if let result = response {
                    let key = coordinateToKey(coordinate: coordinate, isHistory: true)
                    print(key)
                    self.preferencesService.save(requestDTO: result, key: key)
                    single(.success(result))
                }
            } onError: { (error) in
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case .notConnected:
                        let result = self.getStoredHistory(coordinate: coordinate)
                        switch result {
                        case .success(let history):
                            single(.success(history))
                        case .failure(let error):
                            if error == .NotFound {
                                single(.error(error))
                                return
                            }
                        }
                    default:
                        single(.error(error))
                        return
                    }
                }
                
                single(.error(error))
            }.disposed(by: disposeBag)
            
            return Disposables.create {}
        }
    }
    
    func fetchWeather(coordinate: Coordinate) -> Single<WeatherModel> {
        return Single<WeatherModel>.create { [unowned self] single in
            
            self.networkService.request(targetApi: AppApi.fetchWeather(coordinate: coordinate), responseModel: WeatherModel.self).subscribe { [unowned self]  (response) in
                if let result = response {
                    let key = coordinateToKey(coordinate: coordinate)
                    self.preferencesService.save(requestDTO: result, key: key)
                    single(.success(result))
                }
                
            } onError: { [unowned self] (error) in
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case .notConnected:
                        let result =  self.getStoredWeather(coordinate: coordinate)
                        switch result {
                        case .success(let weather):
                            single(.success(weather))
                        case .failure(let error):
                            if error == .NotFound {
                                single(.error(error))
                                return
                            }
                        }
                    default:
                        single(.error(error))
                        return
                    }
                }
                
                single(.error(error))
            }.disposed(by: disposeBag)
            
            return Disposables.create {}
        }
    }
    
    private func getStoredWeather(coordinate: Coordinate) -> Result<WeatherModel, QueryResponseError> {
        
        let key = coordinateToKey(coordinate: coordinate)
        let result = self.preferencesService.getResponse(requestDTO: WeatherModel.self, forKey: key)
        
        switch result {
        case .success(let weather):
            return .success(weather)
        case.failure(let error):
            return .failure(error)
        }
    }
    
    private func getStoredHistory(coordinate: Coordinate) -> Result<History, QueryResponseError> {
        let key = coordinateToKey(coordinate: coordinate)
        let result = self.preferencesService.getResponse(requestDTO: History.self, forKey: key)
        
        switch result {
        case .success(let history):
            return .success(history)
        case.failure(let error):
            return .failure(error)
        }
    }
    
    func setUserChosen() {
        preferencesService.setHasChosen()
    }
    
    private func coordinateToKey(coordinate: Coordinate, isHistory: Bool = false) -> String {
        return isHistory ? "History:\(coordinate.latitude)\(coordinate.longitude)" : "\(coordinate.latitude)\(coordinate.longitude)"
    }
}
