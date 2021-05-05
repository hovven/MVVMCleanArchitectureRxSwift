//
//  AppConfiguration.swift
//  Weather App
//
//  Created by Hossein Vesali Naesh on 5/1/21.
//  Copyright © 2021 Kirtan Patel. All rights reserved.
//

import Foundation

final class AppConfiguration {
    //Add your api key to user_defined in your build settings
    lazy var apiKey: String = {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "ApiKey") as? String else {
            fatalError("ApiKey must not be empty in plist")
        }
        return apiKey
    }()
    
}
