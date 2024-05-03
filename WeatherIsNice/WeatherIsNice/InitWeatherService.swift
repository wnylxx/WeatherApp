//
//  InitWeatherService.swift
//  WeatherIsNice
//
//  Created by wonyoul heo on 5/3/24.
//

import Foundation
import CoreLocation


public final class InitWeatherService: NSObject, CLLocationManagerDelegate, ObservableObject {
    @Published var currentCity: String = ""
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    public func loadLocation() {
        locationManager.startUpdatingLocation()
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation() // 위치 업데이트 중지
        guard let location = locations.last else { return }
        
        Task {
            do {
                let cityName = try await getCityNameFromCoordinates(location: location)
                DispatchQueue.main.async {
                    self.currentCity = cityName
                }
            } catch {
                print("Failed to get city name: \(error)")
            }
        }
    }

    private func getCityNameFromCoordinates(location: CLLocation) async throws -> String {
        let geocoder = CLGeocoder()
        
        return try await withCheckedThrowingContinuation { continuation in
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let placemark = placemarks?.first, let city = placemark.locality else {
                    continuation.resume(throwing: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "City not found"]))
                    return
                }
                
                continuation.resume(returning: city)
            }
        }
    }
}
