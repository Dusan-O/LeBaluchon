//
//  ApiKeys.swift
//  LeBaluchon
//
//  Created by Dusan Orescanin on 24/03/2022.
//

import Foundation

struct APIKeys {
    
    static var weather: String {
        return valueForAPIKey(named: "OPENWEATHERMAP_WEATHER_KEY")
    }
    
    static var translation: String {
        return valueForAPIKey(named: "GOOGLE_TRANSLATION_KEY")
    }
    
    static var currency: String {
        return valueForAPIKey(named: "FIXER_CURRENCY_KEY")
    }
    
    private static func valueForAPIKey(named keyname:String) -> String {
        let filePath = Bundle.main.path(forResource: "ApiKeys", ofType: "plist")
        let plist = NSDictionary(contentsOfFile:filePath!)
        let value = plist?.object(forKey: keyname) as! String
        return value
    }
}
