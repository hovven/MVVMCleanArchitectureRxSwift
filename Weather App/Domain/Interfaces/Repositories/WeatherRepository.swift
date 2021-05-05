//
//  WeatherRepository.swift
//  Weather App
//
//  Created by Hossein Vesali Naesh on 5/3/21.
//  Copyright © 2021 Kirtan Patel. All rights reserved.
//

import Foundation
import RxSwift

protocol WeatherRepository {
    func fetchWeather(coordinate: Coordinate) -> Single<WeatherModel>
    func fetchHistoryData(coordinate: Coordinate) -> Single<History>
    func fetchSearchResults(query: String) -> Single<SearchResult>
    func setUserChosen()
}
