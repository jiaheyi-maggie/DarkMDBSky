//
//  ViewController.swift
//  DarkMDBSky
//
//  Created by Maggie Yi on 3/13/20.
//  Copyright © 2020 Mobile Developers at Berkeley. All rights reserved.
//
import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let manager = CLLocationManager()


    @IBOutlet weak var picker: UIDatePicker!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var coordinateLabel: UILabel!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var dateView: UIView!

    var currentLocation:CLLocation!
    var currentWeather: Weather!
    var defaultUrl: String!
    var url: String!
    var locationURL: String!
    var hasTime: Bool!
    var hasLocation: Bool!
    var secretKey = "https://api.darksky.net/forecast/5e7c06788763764153c9612f71d795bc/"
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        currentLocation = locations[0]
        
        manager.stopUpdatingLocation()
        
        defaultUrl = "\(secretKey)\(currentLocation.coordinate.latitude),\(currentLocation.coordinate.longitude)"

        if hasTime {
            coordinateLabel.text = "\(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)"
            if hasLocation {
                APIrequest(locationURL)
            } else if {
                APIrequest(url)
            }
        } else {
            APIrequest(defaultUrl)
        }
        
    }
    
    func APIrequest(_ urlStr: String) {
        DarkSkyManager.getLocation(urlStr, { data in
            self.currentWeather = data
            DispatchQueue.main.async {
                self.showInfo()
            }
        })
    }
    
    func showInfo() {
        temperatureLabel.text = "\(String(describing: currentWeather!.temperature))˚F"
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yyyy"
        let nsdate = NSDate(timeIntervalSince1970: Double(currentWeather?.time ?? 1583510400))
        let date = Date(date: nsdate)
        let dateStr = df.string(from: date)
        timeLabel.text = "\(dateStr)"
        summaryLabel.text = currentWeather?.summary
        icon.image = UIImage(named: currentWeather!.icon)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dateView.isHidden = true
        hasTime = false
        
        picker.setValue(UIColor.white, forKeyPath: "textColor")
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
    }

    
    @IBAction func confirm(_ sender: Any) {
        
        let unixDate = Int(picker.date.timeIntervalSince1970)
        
        if (unixDate > Int(NSDate().timeIntervalSince1970)) {
            presentAlert("Please provide a date before today")
        }
        
        else {
            hasTime = true
            
            if locationField.text == "" {
                hasLocation = false
                url = defaultUrl + ",\(unixDate)"
                
                locationManager(self.manager, didUpdateLocations: [self.currentLocation])
                
                self.viewDidLoad()
                dateView.isHidden = true
            } else {
                hasLocation = true
                
                getCoordinateFrom(address: locationField.text!) { coordinate, error in
                    guard let coordinate = coordinate, error == nil else {
                        self.presentAlert("Please enter a valid location")
                        return
                    }
                    DispatchQueue.main.async {
                        print(self.locationField.text!, "Location:", coordinate)
                        
                        self.locationURL = "\(self.secretKey)\(coordinate.latitude),\(coordinate.longitude),\(unixDate)"
                        
                        self.currentLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                        
                        self.locationManager(self.manager, didUpdateLocations: [self.currentLocation])
                        self.viewDidLoad()
                        self.dateView.isHidden = true
                    }
                }
            }
        }
    }
    
    
    func presentAlert(_ msg: String) {
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> () ) {
        CLGeocoder().geocodeAddressString(address) { completion($0?.first?.location?.coordinate, $1) }
    }
    
}

extension Date {
    init(date: NSDate) {
        self.init(timeIntervalSinceReferenceDate: date.timeIntervalSinceReferenceDate)
    }
}
