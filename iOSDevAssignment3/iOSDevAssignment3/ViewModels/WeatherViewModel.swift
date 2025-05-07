//
//  WeatherViewModel.swift
//  iOSDevAssignment3
//
//  Created by Mitchell Plass on 7/5/2025.
//

import Foundation
import CoreLocation

class WeatherViewModel : ObservableObject {
    func getCoordinates(destination: Destination) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(destination.name) { (placemarks, error) in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }

            if let placemark = placemarks?.first,
               let location = placemark.location {
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude
                print("Latitude: \(latitude), Longitude: \(longitude)")
            } else {
                print("No location found.")
            }
        }
    }
}
