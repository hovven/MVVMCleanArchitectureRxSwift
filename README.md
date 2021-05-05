# MVVMCleanArchitecture
##Template iOS app using Clean Architecture and MVVM in RxSwift. 
Inspired from [iOS-Clean-Architecture-MVVM](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM#architecture-concepts-used-here)

# Layers

- Domain Layer = Entities + Use Cases + Repositories Interfaces
- Data Repositories Layer = Repositories Implementations + API (Network) + Persistence DB
- Presentation Layer (MVVM) = ViewModels + Views

# Architecture concepts used here

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Advanced iOS App Architecture](https://www.raywenderlich.com/8477-introducing-advanced-ios-app-architecture)
- [MVVM](https://github.com/hovven/MVVMCleanArchitectureRxSwift/tree/main/Weather%20App/Presentation/Weather)
- Data Binding using [RxCocoa](https://github.com/ReactiveX/RxSwift/tree/main/RxCocoa)
- Dependency Injection
- [RxFlow](https://github.com/RxSwiftCommunity/RxFlow) For Navigation
- Data Transfer Object (DTO)
- [Moya](https://github.com/Moya/Moya) For Networking
- [Reusable](https://github.com/AliSoftware/Reusable)
- Error handling examples: in ViewModel, in Networking
