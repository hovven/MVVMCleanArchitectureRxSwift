//
//  NetworkService.swift
//  Weather App
//
//  Created by Hossein Vesali Naesh on 5/1/21.
//  Copyright © 2021 Kirtan Patel. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import Alamofire

protocol HasNetworkService {
    var networkService: NetworkService { get }
}

enum NetworkError: Error {
    case error(statusCode: Int, data: Data?)
    case notConnected
    case cancelled
    case generic(Error)
    case badResponse
}

protocol NetworkService {
    @discardableResult
    func request<E, T>(targetApi: E, responseModel: T.Type) -> Single<T?> where E: TargetType, T: Codable
}

final class DefaultNetworkService : NetworkService {
    
    private let config: NetworkConfigurable
    private let sessionManager: Session
    private let logger: NetworkLoggerPlugin
    
    private let disposeBag = DisposeBag()
    
    public init(config: NetworkConfigurable,
                sessionManager: Session = DefaultSessionManager(),
                logger: NetworkLoggerPlugin = NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))) {
        self.sessionManager = sessionManager
        self.config = config
        self.logger = logger
    }
}

extension DefaultNetworkService {
    
    func request<E, T>(targetApi: E, responseModel: T.Type) -> Single<T?> where E : TargetType, T : Decodable, T : Encodable {
        return Single<T?>.create { [unowned self] single in
            
            let endpointClosure = { (target: E ) -> Endpoint in
                let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
                return defaultEndpoint.adding(newHTTPHeaderFields: config.headers)
            }
            
            let authPlugin = AccessTokenPlugin { _ in config.authToken ?? String() }
            
            let provider = MoyaProvider<E>(endpointClosure: endpointClosure, plugins: [
                                            self.logger, authPlugin])
            
            provider.rx.requestWithProgress(targetApi).subscribe(onNext: {[unowned self] response in
                if let apiResponse = response.response {
                    //if api accidentally return erro in response body
                    if (200...299).contains(apiResponse.statusCode) {
                        let result : Result<T?, NetworkError> = self.responseDecoder(response: apiResponse)
                        switch result {
                        case .success(let data):
                            single(.success(data))
                        case .failure(let error):
                            single(.error(error))
                        }
                    }else{
                        single(.error(NetworkError.error(statusCode: response.response?.statusCode ?? 0, data: response.response?.data)))
                    }
                }
            }, onError: {[unowned self] error in
                let error: NetworkError = self.resolve(error: error)
                single(.error(error))
            }).disposed(by: disposeBag)
            return Disposables.create {}
        }
    }
    
    private func resolve(error: Error) -> NetworkError {
        if let alamofireError = (error as? MoyaError)?.errorUserInfo["NSUnderlyingError"] as? Alamofire.AFError,
                      let underlyingError = alamofireError.underlyingError as NSError?,
                      [NSURLErrorNotConnectedToInternet, NSURLErrorDataNotAllowed].contains(underlyingError.code) {
            return .notConnected
                    }
        
        let code = URLError.Code(rawValue: (error as NSError).code)
        switch code {
        case .notConnectedToInternet , .cannotConnectToHost, .networkConnectionLost: return .notConnected
        case .cancelled: return .cancelled
        default: return .generic(error)
        }
    }
    
    private func responseDecoder<T: Codable>(response: Response) -> Result<T?, NetworkError> {
        
        var isJson = true
        do {
            do {
                _ = try response.mapJSON()
            }catch {
                isJson = false
            }
            
            var body : T?
            if T.self != Nil.self {
                if isJson {
                    body = try response.map(T.self)
                } else {
                    body = nil
                }
            } else {
                body = nil
            }
            return .success(body)
        }catch let error {
            let error: NetworkError = self.resolve(error: error)
            return .failure(error)
        }
    }
    
}

public class DefaultSessionManager: Session {
    static let sharedManager: DefaultSessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        configuration.timeoutIntervalForRequest = 60 // as seconds, you can set your request timeout
        configuration.timeoutIntervalForResource = 60 // as seconds, you can set your resource timeout
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return DefaultSessionManager(configuration: configuration)
    }()
}

struct Nil : Codable {
    
}
