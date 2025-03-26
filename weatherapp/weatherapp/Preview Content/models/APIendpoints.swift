//
//  APIendpoints.swift
//  weatherapp
//
//  Created by Nigam Chaudhary on 14/03/25.
//

import Foundation
enum APIendpoint {
    static let baseurl = "https://api.openweathermap.org"
    case cordinatewithlocationname(String)
    case weatherbylatlon(Double,Double)
    private var path:String{
        switch self{
        case.cordinatewithlocationname(let city):
            return"/geo/1.0/direct?q=\(city)&appid=\(Constants.key.weatherAPIKey)"
        case.weatherbylatlon(let lat,let lon):
            return"/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(Constants.key.weatherAPIKey)"
        }
    }
    static func endpointURL(for endpoint:APIendpoint) ->URL{
        let endpointpath = endpoint.path
        return URL(string: baseurl + endpointpath)!
        
    }
}
