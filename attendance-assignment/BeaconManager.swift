//
//  BeaconManager.swift
//  attendance-assignment
//
//  Created by Maxime Ferraille on 27/04/2018.
//  Copyright © 2018 Maxime Ferraille. All rights reserved.
//

import Foundation
import CoreLocation

let sharedBeaconManager = BeaconManager()

class BeaconManager : NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    let proximityUUID = UUID(uuidString: "F2A74FC4-7625-44DB-9B08-CB7E130B2029")
    let beaconID = "com.attendanceAssignment.BeaconRegion"
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func requestAuthorization(){
        manager.requestWhenInUseAuthorization()
        
        let status = CLLocationManager.authorizationStatus()
        
        if status != .authorizedWhenInUse || status != .authorizedAlways {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func monitorBeacons() {
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
            let beaconRegion = CLBeaconRegion(proximityUUID: proximityUUID!, identifier: beaconID)
            print(beaconRegion)
            self.manager.startMonitoring(for: beaconRegion)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            monitorBeacons()
        }
    }
}
