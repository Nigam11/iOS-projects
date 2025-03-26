//
//  WeatherClient.swift
//  weatherapp
//
//  Created by Nigam Chaudhary on 14/03/25.
//

import Foundation
struct WeatherClient {
func fetchWeather(location: location) async throws -> weather {
    let (data, response) = try await URLSession.shared.data(from: APIendpoint.endpointURL(for: .weatherbylatlon(location.lat,
      location.lon)))
guard let httpResponse = response as? HTTPURLResponse,
httpResponse.statusCode == 200 else {
throw NetworkError.invalidResponse
}
let weatherResponse = try JSONDecoder().decode(weatherresponse.self,from:data)
return weatherResponse.main
}
}
