

import UIKit
import CoreLocation
import Foundation

let apiKey: String = "YOUR_API_KEY"

class ViewController: UIViewController, CLLocationManagerDelegate {
    var weather:WeatherModel?
    let userAsked = UserDefaults.standard.bool(forKey: "hasChosen")
    var coordinate: CLLocationCoordinate2D!
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        coordinate = CLLocationCoordinate2D(latitude: 35.6892, longitude: 51.3890)
        fetchWeather()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(userAsked)
        checkLocationServices()
    }

    func fetchWeather() {
        let urlString = "https://community-open-weather-map.p.rapidapi.com/weather?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)"
        if let url = URL(string: urlString) {
            var urlRequest = URLRequest(url: url)
            urlRequest.setValue("community-open-weather-map.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
            urlRequest.setValue(apiKey, forHTTPHeaderField: "x-rapidapi-key")
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        self.weather = try JSONDecoder().decode(WeatherModel.self, from: data)
                        self.jsonFetched(weather: self.weather!)
                    } catch let error {
                        print(error)
                    }
                }
                }.resume()
        }
    }

    func jsonFetched(weather: WeatherModel) {
        print(weather.main?.temp)
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
            checkLocationAuthorization()
            print(getLatLong())
        } else {
            if userAsked == false { showLocationServicesOffPopUp() }
        }
    }
    
    func checkLocationAuthorization() {
        print("Location Authorization Check")
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            if userAsked == false { showLocationDisabledPopUp() }
            break
        case .authorizedAlways:
            break
        case .denied:
            if userAsked == false { showLocationDisabledPopUp() }
            break
        @unknown default:
            break
        }
    }
    
    func getLatLong() -> Array<Any> {
        let currentLocation = locationManager.location
        let longitude = currentLocation?.coordinate.longitude as Any
        let latitude = currentLocation?.coordinate.latitude as Any
        
        return [latitude, longitude]
    }

    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Location Access Disabled", message: "Please allow Location Services to enable automatic local weather", preferredStyle: .actionSheet)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (ACTION) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        self.present(alertController, animated: true, completion: nil)
        UserDefaults.standard.set(true, forKey: "hasChosen")
    }
    
    func showLocationServicesOffPopUp() {
        let alertController = UIAlertController(title: "Device Location Services Disabled", message: "Please allow Location Services to enable automatic local weather", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        UserDefaults.standard.set(true, forKey: "hasChosen")
    }

}
