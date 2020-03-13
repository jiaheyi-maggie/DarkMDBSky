//
//  DarkSkyManager.swift
//  DarkMDBSky
//
//  Created by Maggie Yi on 3/13/20.
//  Copyright © 2020 Mobile Developers at Berkeley. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class DarkSkyManager {
    
    static func getLocation(_ urlStr:String, _ completion: @escaping (Weather) -> ()) {
        
        guard let url = URL(string: urlStr) else {
            return
        }
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            
            // Decode JSON and serialization
            let request = try! JSONDecoder().decode(WeatherRequest.self, from: data)
            completion(request.currently)
            
        }
        task.resume()
    }
}
