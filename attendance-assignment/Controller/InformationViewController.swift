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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // We used ur custom beacon manager to ask authorization and monitor beacons
        sharedBeaconManager.requestAuthorization()
        sharedBeaconManager.monitorBeacons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func navigateToScanner(_ sender: Any) {
        if beaconsArray.isEmpty {
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
