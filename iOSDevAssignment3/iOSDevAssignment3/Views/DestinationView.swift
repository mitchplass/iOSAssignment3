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
            VStack {
                Image(systemName: "info.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)
                    .padding(.bottom, 20)
                
                Text("This is the Destination Page")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Here you can view weather information about your destination")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 16) {
                    if let weatherData = weatherViewModel.weatherData {
                        WeatherRow(label: "Condition:", value: "\(weatherData.weather.first?.description ?? "N/A")")
                        WeatherRow(label: "Condition:", value: "\(weatherData.weather.first?.description ?? "N/A")")
                        WeatherRow(label: "Temp:", value: "\(weatherData.main.temp)°C")
                        WeatherRow(label: "Feels Like:", value: "\(weatherData.main.feels_like)°C")
                        WeatherRow(label: "Min Temp:", value: "\(weatherData.main.temp_min)°C")
                        WeatherRow(label: "Max Temp:", value: "\(weatherData.main.temp_max)°C")
                        WeatherRow(label: "Humidity:", value: "\(weatherData.main.humidity)%")
                        WeatherRow(label: "Pressure:", value: "\(weatherData.main.pressure) hPa")
                        WeatherRow(label: "Wind Speed:", value: "\(weatherData.wind.speed) m/s")
                        WeatherRow(label: "Wind Direction:", value: "\(weatherData.wind.deg)°")
                        WeatherRow(label: "Wind Gust:", value: "\(weatherData.wind.gust ?? 0.0) m/s")
                        WeatherRow(label: "Cloud Coverage:", value: "\(weatherData.clouds.all)%")
                        WeatherRow(label: "Visibility:", value: "\(weatherData.visibility / 1000) km")
                        WeatherRow(label: "Sunrise:", value: "\(DateFormatter.localizedString(from: Date(timeIntervalSince1970: TimeInterval(weatherData.sys.sunrise)), dateStyle: .none, timeStyle: .short))")
                        WeatherRow(label: "Sunset:", value: "\(DateFormatter.localizedString(from: Date(timeIntervalSince1970: TimeInterval(weatherData.sys.sunset)), dateStyle: .none, timeStyle: .short))")
                        Map {
                            Marker(destination, coordinate: CLLocationCoordinate2D(latitude: weatherData.coord.lat, longitude: weatherData.coord.lon))
                                .tint(.red)
                        }
                        .frame(height: 300)
                        .cornerRadius(15)
                        .shadow(radius: 10)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .padding()
                
                Spacer()
            }
            .padding(.top, 40)
            .onAppear {
                weatherViewModel.getWeather(destination: destination)
            }
        }
    }
}

struct WeatherRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .fontWeight(.medium)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

#Preview {
    DestinationView(destination: "Melbourne")
}
