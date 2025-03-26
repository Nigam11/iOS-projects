//
//  weather.swift
//  weatherapp
//
//  Created by Nigam Chaudhary on 14/03/25.
//

import Foundation
struct weatherresponse: Decodable{
    let main: weather
}
struct weather: Decodable{
    let temp: Double
}
