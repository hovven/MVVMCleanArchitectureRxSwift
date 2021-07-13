//
//  WeatherResponseStorage.swift
//  Weather App
//
//  Created by Hossein Vesali Naesh on 5/3/21.
//  Copyright © 2021 Hoven. All rights reserved.
//

import Foundation

protocol WeatherResponseStorage {
    func getResponse<T: Codable>(requestDTO: T.Type, forKey key: String) -> Result<T, QueryResponseError>
    func save <T: Codable>(requestDTO: T, key: String)
}
