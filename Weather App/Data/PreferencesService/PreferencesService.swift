//
//  PreferencesService.swift
//  Weather App
//
//  Created by Hossein Vesali Naesh on 5/1/21.
//  Copyright © 2021 Kirtan Patel. All rights reserved.
//

import Foundation
import RxSwift

enum QueryResponseError : Error {
    case NotFound
}

final class PreferencesService {
    private let defaults = UserDefaults.standard
    
    struct UserPreferences {
        private init() {}
        static let userAsked = "hasChosen"
    }
}

extension PreferencesService : WeatherResponseStorage, LocationServiceResponseStorage {
    
    func getResponse<T: Codable>(requestDTO: T.Type, forKey key: String) -> Result<T, QueryResponseError> {
        if let object = self.get(requestDTO: requestDTO, key: key) {
            return .success(object)
        }else{
            return .failure(QueryResponseError.NotFound)
        }
    }
    
    func save <T: Codable>(requestDTO: T, key: String) {
        defaults.set(try? PropertyListEncoder().encode(requestDTO), forKey: key)
        sync()
    }
    
    private func get <T:Decodable> (requestDTO: T.Type, key: String) -> T? {
        do{
            let jsonData : Data? = defaults.value(forKey: key) as? Data
            
            if let data = jsonData {
                return try PropertyListDecoder().decode(requestDTO, from: data)
            } else {
                return nil
            }
        }catch{
            
        }
        return T.self as? T
    }
    
    func setHasChosen() {
        defaults.set(true, forKey: UserPreferences.userAsked)
        sync()
    }
    
    
    func setNotChosen() {
        defaults.removeObject(forKey: UserPreferences.userAsked)
        sync()
    }
    
    
    func hasChosen () -> Bool {
        return defaults.bool(forKey: UserPreferences.userAsked)
    }
    
    private func sync() {
        defaults.synchronize()
    }
}

extension PreferencesService: ReactiveCompatible {}

extension Reactive where Base: PreferencesService {
    var hasChosen: Observable<Bool> {
        return UserDefaults.standard
            .rx
            .observe(Bool.self, PreferencesService.UserPreferences.userAsked)
            .map {$0 ?? false}
    }
}
