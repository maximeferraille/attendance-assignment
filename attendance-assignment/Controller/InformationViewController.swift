//
//  InformationViewController.swift
//  attendance-assignment
//
//  Created by Maxime Ferraille on 26/04/2018.
//  Copyright © 2018 Maxime Ferraille. All rights reserved.
//

import UIKit
import CoreLocation

class InformationViewController: UIViewController, CLLocationManagerDelegate {
    
    var beaconsArray = [Int]()
    @IBOutlet var dateLabel : UILabel!
    @IBOutlet var locationLabel : UILabel!
    @IBOutlet var presentLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateLabel.font = UIFont.fontAwesome(ofSize: 14)
        dateLabel.placeholder = String.fontAwesomeIcon(code: "fa-envelope")
        locationLabel.font = UIFont.fontAwesome(ofSize: 20)
        locationLabel.placeholder = String.fontAwesomeIcon(code: "fa-key")
        self.view.backgroundColor = UIColor.MainColor.Purple.mainPurple
        
        // We used ur custom beacon manager to ask authorization and monitor beacons
        sharedBeaconManager.requestAuthorization()
        sharedBeaconManager.monitorBeacons()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear()
        
        //When view appear we check if the room as changed by comparing current room in appDelagate with a new getlocation api call
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let userToken   = appDelegate?.userToken
        
        if userToken != nil {
            let url = URL(string: "http://localhost/api/getLocation")!
            let session = URLSession.shared
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: userToken, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
            }
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                guard error == nil else {
                    return
                }
                guard let data = data else {
                    return
                }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        if let date = json["date"] as? String {
                            dateLabel.text = location
                        }
                        if let location = json["location"] as? String {
                            if location != locationLabel.text {
                                appDelegate?.isPresent = false
                            }
                            locationLabel.text = location
                        }
                        appDelegate.currentRoom = location
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            })
            task.resume()
        }
        
        if appDelegate?.isPresent {
            presentLabel.textColor = UIColor.red
            presentLabel.text = "Non présent"
        } else {
            presentLabel.textColor = UIColor.green
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func navigateToScanner(_ sender: Any) {
        if !beaconsArray.isEmpty {
            if let next = self.storyboard?.instantiateViewController(withIdentifier : "scanner") as? ScannerViewController {
                next.beaconsArray = beaconsArray
                self.navigationController?.pushViewController(next, animated: true)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion){
        for b in beacons {
            let major = Int(truncating: b.major)
            let minor = Int16(truncating: b.minor)
            
            //Conform to the api we create a integer who concact major value in 32bits and minor value in 16bits
            let beacon = Int(String(major) + String(minor))
            beaconsArray.append(beacon!)
        }
    }
}
