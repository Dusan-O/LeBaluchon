//
//  WeatherViewController.swift
//  LeBaluchon
//
//  Created by Dusan Orescanin on 24/03/2022.
//

import UIKit

class WeatherViewController: UIViewController {
    
    let weatherModel = Weather()
    
    @IBOutlet var citiesSegmented: UISegmentedControl!
    @IBOutlet var date: UILabel!
    @IBOutlet var descriptionWeather: UILabel!
    @IBOutlet var currentTemperature: UILabel!
    @IBOutlet var minTemperature: UILabel!
    @IBOutlet var maxTemperature: UILabel!
    @IBOutlet var humidity: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            citiesSegmented.selectedSegmentTintColor = UIColor(named: "Gris")!
        } else {
            citiesSegmented.tintColor = UIColor(named: "Gris")!
        }
        
        // This function is called in viewDidLoad to ask the model the weather information of the current selected city. By default, the index is 0, which in the model coresponds to Nantes.
        citySwitched(citiesSegmented)
    }
    
    @IBAction func citySwitched(_ sender: UISegmentedControl) {
        weatherModel.request(from: citiesSegmented.selectedSegmentIndex) { (result) in
            switch result {
            case let .success(response):

                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .full
                dateFormatter.timeStyle = .none
                
                let date = Date(timeIntervalSince1970: response.dt)
                dateFormatter.locale = Locale(identifier: "fr_FR")
                dateFormatter.setLocalizedDateFormatFromTemplate("EEEEdMMMM")
                
                let formattedDate = dateFormatter.string(from: date)
                
                self.date.text = "\(formattedDate)"
                self.currentTemperature.text = "\(response.main.temp)ºC"
                self.minTemperature.text = "\(response.main.temp_min)ºC"
                self.maxTemperature.text = "\(response.main.temp_max)ºC"
                self.humidity.text = "\(response.main.humidity)%"
                
                // Use of type safe first API in case of the weather array is empty, displaying a default text on that case
                if let description = response.weather.first?.description {
                    self.descriptionWeather.text = description
                } else {
                    self.descriptionWeather.text = "Il n'y a pas de données serveur"
                }

            case let .failure(error):
                self.presentUIAlert(message: error.message)
            }
        }
    }
}
