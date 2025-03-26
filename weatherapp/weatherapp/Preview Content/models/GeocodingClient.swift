//
//  GeocodingClients.swift
//  weatherapp
//
//  Created by Nigam Chaudhary on 14/03/25.
//

import Foundation
enum NetworkError: Error {
case invalidResponse
}
struct GeocodingClient {
func coordinateByCity(_ city: String) async throws -> location? {
    let (data, response) = try await URLSession.shared.data(from: APIendpoint.endpointURL(for: .cordinatewithlocationname(city)))
guard let httpResponse = response as? HTTPURLResponse,
httpResponse.statusCode == 200 else {
throw NetworkError.invalidResponse
}
    let location = try JSONDecoder().decode([location].self, from: data)
     return location.first
}
}
