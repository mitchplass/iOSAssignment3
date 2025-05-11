//
//  WeatherViewModel.swift
//  iOSDevAssignment3
//
//  Created by Mitchell Plass on 7/5/2025.
//

import Foundation
import CoreLocation
import SwiftUI

class WeatherViewModel : ObservableObject {
    @Published var weatherData: WeatherData?
    @Published var errorString = ""
    var apiKey = "96e26291dc1f7032f20351ff609a7127"
    
    func getWeather(destination: String) {
        getCoordinates(from: destination) { coordinates, error in
            if error != nil {
                self.errorString = "Failed to gather weather data"
            } else if let coordinates = coordinates {
                self.requestWeatherData(coordinates: coordinates) { result in
                    switch result {
                    case .success(let weatherData):
                        self.weatherData = weatherData
                    case .failure(_):
                        self.errorString = "Failed to get weather data"
                    }
                }
            } else {
                self.errorString = "Failed to gather weather data"
            }
        }
    }
    
    func requestWeatherData(coordinates: CLLocationCoordinate2D, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let weatherData = try decoder.decode(WeatherData.self, from: data)
                    completion(.success(weatherData))
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(NSError(domain: "No data", code: -2)))
            }
        }
        
        task.resume()
    }
    
    func getCoordinates(from address: String, completion: @escaping (CLLocationCoordinate2D?, Error?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            if let placemark = placemarks?.first, let location = placemark.location {
                let coordinates = location.coordinate
                completion(coordinates, nil)
            } else {
                completion(nil, nil)
            }
        }
    }
}
