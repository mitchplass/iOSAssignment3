//
//  DestinationView.swift
//  iOSDevAssignment3
//
//  Created by Mitchell Plass on 8/5/2025.
//

import SwiftUI
import MapKit

struct DestinationView: View {
    @State var destination: String
    @StateObject var weatherViewModel = WeatherViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(destination)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Weather Forecast")
                        .font(.headline)
                        .foregroundColor(.gray)

                    if let weatherData = weatherViewModel.weatherData {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Condition: \(weatherData.weather.first?.description ?? "N/A")")
                            Text("Temperature: \(String(format: "%.1f", weatherData.main.temp))°C")
                            Text("Feels Like: \(String(format: "%.1f", weatherData.main.feels_like))°C")
                            Text("Humidity: \(weatherData.main.humidity)%")
                            Text("Pressure: \(weatherData.main.pressure) hPa")
                            Text("Wind: \(String(format: "%.1f", weatherData.wind.speed)) m/s")
                        }
                        .font(.body)
                        .foregroundColor(.primary)
                    } else {
                        Text("Loading weather data...")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Local Time")
                        .font(.headline)
                        .foregroundColor(.gray)
                    if let weatherData = weatherViewModel.weatherData {
                        Text("Sunrise: \(formatTime(weatherData.sys.sunrise))")
                        Text("Sunset: \(formatTime(weatherData.sys.sunset))")
                    } else {
                        Text("Loading local time...")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()

                if let weatherData = weatherViewModel.weatherData {
                    Map {
                        Marker(destination, coordinate: CLLocationCoordinate2D(latitude: weatherData.coord.lat, longitude: weatherData.coord.lon))
                            .tint(.red)
                    }
                    .frame(height: 300)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                }

            }
            .padding(.horizontal)
        }
        .onAppear {
            weatherViewModel.getWeather(destination: destination)
        }
    }

    private func formatTime(_ unixTime: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(unixTime))
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
    }
}

#Preview {
    DestinationView(destination: "Melbourne")
}
