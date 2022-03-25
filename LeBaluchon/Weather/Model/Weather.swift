//
//  Weather.swift
//  LeBaluchon
//
//  Created by Dusan Orescanin on 24/03/2022.
//

import Foundation

class Weather {
    
    let session: RequestInterface
    
    let apiKey: String
    
    // Default arguments in function
    init(session: RequestInterface = URLSession.shared,
         apiKey: String = APIKeys.weather) {
        self.session = session
        self.apiKey = apiKey
    }
    
    func request(from cityIndex: Int, then: @escaping (Result<LatestWeatherResponse, WeatherError>) -> Void) {
        
        let citySelected: String
        switch cityIndex {
        case 0:
            citySelected = "paris,fr"
        case 1:
            citySelected = "new york,us"
        default:
            citySelected = "paris,fr"
        }
        
        // Use of URLComponents to construct the URL with the required parameters to request to openweathermap API weather info about a city
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.openweathermap.org"
        urlComponents.path = "/data/2.5/weather"
        
        urlComponents.queryItems = [URLQueryItem(name: "q", value: citySelected),
                                    URLQueryItem(name: "mode", value: "json"),
                                    URLQueryItem(name: "lang", value: "fr"),
                                    URLQueryItem(name: "units", value: "metric"),
                                    URLQueryItem(name: "APPID", value: apiKey)]
        
        // If this fails, it's because a programming error -> wrong URL
        guard let url = urlComponents.url else {
            fatalError("Invalid URL")
        }
        
        // Sets the request as GET
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            
            // Verifies if the request threw an error
            if let error = error as NSError? {
                DispatchQueue.main.async {
                    then(.failure(.requestError(error)))
                }
                return
            }
            
            // Verifies that the received JSON in the server response has a format that we expect
            guard let data = data,
                let responseJSON = try? JSONDecoder().decode(LatestWeatherResponse.self, from: data) else {
                    DispatchQueue.main.async {
                        then(.failure(.invalidResponseFormat))
                    }
                    return
            }
            
            // if both condition above are satisfied, it provides an instance of LatestWeatherResponse object, which reprensents the response received from the server, along with the Result's success case back to the caller
            DispatchQueue.main.async {
                then(.success(responseJSON))
            }
        })
        task.resume()
    }
}
