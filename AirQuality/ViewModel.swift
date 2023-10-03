//
//  ViewModel.swift
//  AirQuality
//
//  Created by Karan Doshi on 10/1/23.
//

import Foundation
import MapKit
import Observation
import SwiftUI
import XCAAQI

//struct Location: Identifiable {
//    var id = UUID()
//    var coordinate: CLLocationCoordinate2D
//    var aqIndex: String
//}
enum LocationStatus: Equatable {
    case requstingLocation
    case locationNotAuthorized(String)
    case error(String)
    case requestingAQIConditions
    case standby
}

@Observable
class ViewModel {
    
    let aqiClient = AirQualityClient(apiKey: "AIzaSyCjSHYcpVE-iSSxJl5uYtpUAKJKQ2t4LXg")
    let coordinateFinder = CoordinatesFinder()
    var currentLocation: CLLocationCoordinate2D?
    var locationStatus = LocationStatus.requstingLocation
    var position: MapCameraPosition = .automatic
    var annotations: [AQIResponse] = []
    var selection: AQIResponse?
    var presentationDetent = PresentationDetent.height(150)
    
    var radiusNArray: [(Double, Int)]
    var lat: Double = 0
    var long: Double = 0
    
    init(radiusNArray: [(Double, Int)] = [(4000,6), (8000,12)])
    {
        self.radiusNArray = radiusNArray
        self.currentLocation = .init(latitude:47.608013, longitude:-122.335167)
        Task {
            await self.handleCoordinateChange(currentLocation!)
        }
    }
    
    func handleCoordinateChange(_ coordinate: CLLocationCoordinate2D) async {
        do {
            self.locationStatus = .requestingAQIConditions
            self.position = .region(.init(center: coordinate, latitudinalMeters: 0, longitudinalMeters: 16000))
            let coordinates = getCoordinatesAround(coordinate)
            self .annotations = try await aqiClient.getCurrentConditions(coordinates: coordinates.map{($0.latitude,$0.longitude)})
            self .locationStatus = .standby
        } catch {
            self.locationStatus = .error(error.localizedDescription)
        }
    }
    
    func getCoordinatesAround(_ coordinate: CLLocationCoordinate2D) -> [CLLocationCoordinate2D] {
        var results: [CLLocationCoordinate2D] = [coordinate]
        radiusNArray.forEach {
            results += coordinateFinder.findCoordinates(coordinate, r: $0.0, n: $0.1)
        }
        return results
    }
}

