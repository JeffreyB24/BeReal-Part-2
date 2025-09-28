//
//  OneShotLocation.swift
//  Codepath-HW2
//
//  Created by Jeffrey Berdeal on 9/26/25.
//

import CoreLocation

final class OneShotLocation: NSObject, CLLocationManagerDelegate {
    static let shared = OneShotLocation()
    private let mgr = CLLocationManager()
    private var cont: ((CLLocationCoordinate2D?) -> Void)?

    func request(_ completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        cont = completion
        mgr.delegate = self
        if mgr.authorizationStatus == .notDetermined {
            mgr.requestWhenInUseAuthorization()
        } else if mgr.authorizationStatus == .denied || mgr.authorizationStatus == .restricted {
            completion(nil)
            return
        }
        mgr.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        } else if status == .denied || status == .restricted {
            cont?(nil); cont = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        cont?(locations.first?.coordinate); cont = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        cont?(nil); cont = nil
    }
}
