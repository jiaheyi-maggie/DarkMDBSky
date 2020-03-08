//
//  WeatherJson.swift
//  DarkMDBSky
//
//  Created by Maggie Yi on 3/5/20.
//  Copyright © 2020 Mobile Developers at Berkeley. All rights reserved.
//

import Foundation

struct Weather {
    // 1. initializer to accept JSON object
    let summary: String
    let icon: String
    let temperature: Double
    
    //create error type
    enum SerializationError: Error {
        case missing(String)
        case invalid(String, Any)
        
    }
    // parse JSON to dictionary
    init(json:[String: Any]) throws {
        //throw error for serialization
        guard (json["summary"] as? String) != nil else {throw SerializationError.missing("Summary is missing")}
        
        guard (json["icon"] as? String) != nil else {throw SerializationError.missing("Icon is missing")}
        
        guard (json["temperature"] as? Double) != nil else {throw SerializationError.missing("Temperature is missing")}
        
        //initialize
        self.summary = json["summary"] as! String
        self.icon = json["icon"] as! String
        self.temperature = json["temperature"] as! Double
        
    }
    
    // 2. method: make HTTP request to API for asynchrnous data
    static let basePath = "https://api.darksky.net/forecast/c3ab7ee27d89a729d4919eab19be829f"
    static func forecast(withLocation location: String, completion: @escaping ([Weather])->() ) {
        // access latitude and longtitude?? 
        let url = basePath + "\(location.latitude), \(location.longtitude)"
        let request = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            var forcastArray : [Weather] = []
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                        if let dailyForcast = json["daily"] as? [String: Any] {
                            if let dailyData = dailyForcast["data"] as? [[String: Any]] {
                                //iterate through different data objects
                                for dataPoint in dailyData {
                                    if let weatherObject = try? Weather(json: dataPoint) {
                                        forcastArray.append(weatherObject)
                                    }
                                }
                            }
                        }
                    }
                }
                catch{
                    print(error.localizedDescription)
                }
                completion(forcastArray)
            }
        }
        
        task.resume()
    }
}
