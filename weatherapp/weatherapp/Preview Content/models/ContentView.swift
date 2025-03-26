//
//  ContentView.swift
//  weatherapp
//
//  Created by Nigam Chaudhary on 14/03/25.
//

import SwiftUI

struct ContentView: View {
    @State private var city: String = ""
    @State private var isFetchingWeather: Bool = false
    let geocodingclient = GeocodingClient()
    let weatherClient = WeatherClient()
    @State private var weather : weather?
    private func fetchWeather() async{
        do{
            guard let location = try await geocodingclient.coordinateByCity(city) else { return }
            weather = try await weatherClient.fetchWeather(location: location)
            
        }catch {
            print(error)
        }
    }
    var body: some View {
        VStack {
            TextField("City",text: $city)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    isFetchingWeather = true
                }.task(id: isFetchingWeather){
                    if isFetchingWeather{
                        await fetchWeather()
                        isFetchingWeather = false
                        city = ""
                    }
                }
            Spacer()
            if let weather {
                Text(MeasurementFormatter.temperature(value: weather.temp))
                    .font(.system(size: 100))
            }
            Spacer()
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
