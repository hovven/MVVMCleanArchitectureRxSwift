# MVVMCleanArchitecture
Template iOS app using Clean Architecture and MVVM in RxSwift. Inspired from https://github.com/kudoleh/iOS-Clean-Architecture-MVVM#architecture-concepts-used-here

# Layers

- Domain Layer = Entities + Use Cases + Repositories Interfaces
- Data Repositories Layer = Repositories Implementations + API (Network) + Persistence DB
- Presentation Layer (MVVM) = ViewModels + Views

# Architecture concepts used here

Clean Architecture https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
Advanced iOS App Architecture https://www.raywenderlich.com/8477-introducing-advanced-ios-app-architecture
MVVM
Data Binding using RxSwift
Dependency Injection
RxFlow Coordinator
Data Transfer Object (DTO)
UIKit view implementations by reusing same ViewModel (at least Xcode 11 required)
Error handling examples: in ViewModel, in Networking

#
