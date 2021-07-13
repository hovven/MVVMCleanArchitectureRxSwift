//
//  ViewModelBased.swift
//  Weather App
//
//  Created by Hossein Vesali Naesh on 5/1/21.
//  Copyright © 2021 Hoven. All rights reserved.
//

import Foundation
import Foundation
import Reusable

protocol ViewModel {
    
}

protocol ServicesViewModel: ViewModel {
    associatedtype UseCase
    var usecas: UseCase! { get set }
}

protocol ViewModelBased: class {
    associatedtype ViewModelType
    var viewModel: ViewModelType! { get set }
}

extension ViewModelBased where Self: UIViewController & StoryboardBased {
    static func instantiate<ViewModelType>(withViewModel viewModel: ViewModelType) -> Self where ViewModelType == Self.ViewModelType {
        let viewController = Self.instantiate()
        viewController.viewModel = viewModel
        return viewController
    }
}

extension ViewModelBased where Self: UIViewController & StoryboardBased, ViewModelType: ServicesViewModel {
    static func instantiate<ViewModelType, ServicesType>(withViewModel viewModel: ViewModelType, andServices services: ServicesType) -> Self where ViewModelType == Self.ViewModelType, ServicesType == Self.ViewModelType.UseCase {
        let viewController = Self.instantiate()
        viewController.viewModel = viewModel
        viewController.viewModel.usecas = services
        return viewController
    }
}
