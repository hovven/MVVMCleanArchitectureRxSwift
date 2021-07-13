//
//  ServiceConfig.swift
//  Weather App
//
//  Created by Hossein Vesali Naesh on 5/2/21.
//  Copyright © 2021 Hoven. All rights reserved.
//

import Foundation

public protocol NetworkConfigurable {
    var authToken: String? { get }
    var headers: [String: String] { get }
}

public struct ApiDataNetworkConfig: NetworkConfigurable {
    public let headers: [String: String]
    public let authToken: String?
    
     public init(headers: [String: String] = [:],
                 authToken: String? = String()) {
        self.headers = headers
        self.authToken = authToken
    }
}


