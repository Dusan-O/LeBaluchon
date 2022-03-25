//
//  LatestWeatherResponse.swift
//  LeBaluchon
//
//  Created by Dusan Orescanin on 24/03/2022.
//

import Foundation

// Represents the JSON response for the OpenWeather API to get weather information about a city. The JSON structure is represented by the the different structs defined in this file
struct LatestWeatherResponse: Codable, Equatable {
    let main: MainResponse
    let weather: [DescriptionResponse]
    let dt: TimeInterval
}

struct MainResponse: Codable, Equatable {
    let temp: Double
    let humidity: Int
    let temp_min: Double
    let temp_max: Double
}

struct DescriptionResponse: Codable, Equatable {
    let description: String
}
