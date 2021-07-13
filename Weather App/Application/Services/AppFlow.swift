//
//  AppFlow.swift
//  Weather App
//
//  Created by Hossein Vesali Naesh on 5/1/21.
//  Copyright © 2021 Hoven. All rights reserved.
//

import UIKit
import RxFlow
import RxCocoa
import RxSwift

class AppFlow: Flow {
    var root: Presentable {
        return self.rootViewController
    }
    
    private lazy var rootViewController: UINavigationController = {
        let viewController = UINavigationController()
        viewController.setNavigationBarHidden(true, animated: false)
        return viewController
    }()
    
    private let appDIContainer: AppDIContainer
    
    init(appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
    }
    
    deinit {
        print("\(type(of: self)): \(#function)")
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? WeatherStep else { return .none }
        
        switch step {
        case .WeatherAreRequired:
            return navigationToWeatherScreen()
//        default:
//            return .none
        }
    }
    
    private func navigationToWeatherScreen() -> FlowContributors {
        let viewController = WeatherViewController.instantiate(withViewModel: WeatherViewModel(), andServices: self.appDIContainer.makeWeatherDIContainer().makeWeatherUseCase())
        viewController.title = "Weather"
        
        self.rootViewController.pushViewController(viewController, animated: true)
        return .none
    
    }
    
}

