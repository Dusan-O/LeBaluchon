//
//  WeatherError.swift
//  LeBaluchon
//
//  Created by Dusan Orescanin on 24/03/2022.
//

import Foundation

enum WeatherError: Error, Equatable {
    case requestError(NSError)
    case invalidResponseFormat
}

extension WeatherError {
    var message: String{
        switch self {
        case let .requestError(error):
            return error.localizedDescription
        case .invalidResponseFormat:
            return "Le format de réponse du serveur est invalide "
        }
    }
}
