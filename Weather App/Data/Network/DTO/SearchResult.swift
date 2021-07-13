//
//  SearchResult.swift
//  Weather App
//
//  Created by Hossein Vesali Naesh on 5/2/21.
//  Copyright © 2021 Hoven. All rights reserved.
//

import Foundation
// MARK: - SearchResult
struct SearchResult: Codable {
    let count: Int?
    let list: [WeatherModel]
}
