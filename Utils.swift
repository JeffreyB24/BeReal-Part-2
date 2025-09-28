//
//  Utils.swift
//  Codepath-HW2
//
//  Created by Jeffrey Berdeal on 9/18/25.
//

import Foundation
import CoreLocation
import ParseSwift

final class PlaceFormatter: NSObject, ObservableObject {
    static let shared = PlaceFormatter()
    private let geocoder = CLGeocoder()
    private var cache: [String: String] = [:]

    func name(for coordinate: CLLocationCoordinate2D) async -> String? {
        let key = "\(coordinate.latitude),\(coordinate.longitude)"
        if let cached = cache[key] { return cached }
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(
                CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            )
            if let p = placemarks.first {
                let city = p.locality ?? p.subLocality ?? ""
                let region = p.administrativeArea ?? p.country ?? ""
                let name = [city, region].filter { !$0.isEmpty }.joined(separator: ", ")
                cache[key] = name
                return name
            }
        } catch { /* ignore errors */ }
        return nil
    }
}
