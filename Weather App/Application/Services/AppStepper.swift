//
//  AppStepper.swift
//  Weather App
//
//  Created by Hossein Vesali Naesh on 5/1/21.
//  Copyright © 2021 Kirtan Patel. All rights reserved.
//

import RxFlow
import RxSwift
import RxCocoa

class AppStepper: Stepper {
    
    let steps = PublishRelay<Step>()
    private let appDIContainer: AppDIContainer
    private let disposeBag = DisposeBag()
    
    init(withServices appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
    }
    
    var initialStep: Step {
        return WeatherStep.WeatherAreRequired
    }
    
    func readyToEmitSteps() {
        
    }
}

