//
//  ForecastViewModel.swift
//  TestWeatherApp
//
//  Created by wonyoul heo on 5/2/24.
//

import Foundation
import CoreLocation





struct TemperatureInfo {
    let date: String
    let minTemp: Double
    let maxTemp: Double
    let iconCode: String
}

class ForecastListViewModel: ObservableObject {
    
    @Published var forecasts: [ForecastViewModel] = []
    @Published var temperatureInfoPerDay: [TemperatureInfo] = []
    
    var location: String = ""
    
    func getWeatherForecast() {
        let apiService = ForecastAPIService.shared
        
        CLGeocoder().geocodeAddressString(location) {(placemarks, error) in    // CLGeocoder() : 지정된 위치의 위도 및 경도
            if let error = error {
                print(error.localizedDescription)
            }
            if let lat = placemarks?.first?.location?.coordinate.latitude,
               let lon = placemarks?.first?.location?.coordinate.longitude {  // getJSON : 비동기적으로 데이터를 가져온다. // async 로 쓰는 코드로 바꾸세요.
                apiService.getJSON(urlString: "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&lang=kr&appid=ce878d5130eaace7c56141ff9190f16f&units=metric", dateDecodingStrategy: .secondsSince1970) {
                    (result: Result<Forecast,ForecastAPIService.APIError>) in
                    switch result {
                    case .success(let forecast):
                        DispatchQueue.main.async { [self] in                // 주어진 클로저를 메인 스레드에서 비동기적으로 실행 하겠다. -> 데이터를 받아오면 UI 업데이트를 수행하겠다.
                            self.forecasts = forecast.list.map {ForecastViewModel(forecast: $0)}
                            self.temperatureInfoPerDay = self.calculateTemperatureInfoPerDay(from: forecasts)
                        }// @State
                    case .failure(let apiError):
                        switch apiError {
                        case .error(let errorString):
                            print(errorString)
                        }
                    }
                }
            }
        }
    }
    
    private func calculateTemperatureInfoPerDay(from forecasts: [ForecastViewModel]) -> [TemperatureInfo] {
        var temperatureInfoPerDay: [TemperatureInfo] = []
        var tempInfoDict: [String: TemperatureInfo] = [:]
        
        var iconCodeCountDict: [String: [String: Int]] = [:]
        for forecast in forecasts {
            let date = forecast.shortday
            if iconCodeCountDict[date] == nil {
                iconCodeCountDict[date] = [:]  // 요일 별 배열 초기화
            }
            if let count = iconCodeCountDict[date]?[forecast.iconCode] {
                iconCodeCountDict[date]?[forecast.iconCode] = count + 1  // 이중 for 문 ;;
            } else {
                iconCodeCountDict[date]?[forecast.iconCode] = 1
            }
        }
        
        
        for forecast in forecasts {
            let date = forecast.shortday
            if let existingTempInfo = tempInfoDict[date] {
                let minTemp = min(existingTempInfo.minTemp, forecast.forecast.main.temp_min)
                let maxTemp = max(existingTempInfo.maxTemp, forecast.forecast.main.temp_max)
                
                // 가장 많이 등장한 아이콘 찾기 (없으면 첫번째 데이터)
                let mostFrequentIconCode = iconCodeCountDict[date]?.max { $0.value < $1.value }?.key ?? forecasts[0].iconCode
                
                let updatedTempInfo = TemperatureInfo(date: date, minTemp: minTemp, maxTemp: maxTemp, iconCode: mostFrequentIconCode)
                tempInfoDict[date] = updatedTempInfo
            } else {
                let mostFrequentIconCode = iconCodeCountDict[date]?.max { $0.value < $1.value }?.key ?? forecasts[0].iconCode
                let tempInfo = TemperatureInfo(date: date, minTemp: forecast.forecast.main.temp_min, maxTemp: forecast.forecast.main.temp_max, iconCode: mostFrequentIconCode)
                tempInfoDict[date] = tempInfo
            }
        }
        
        // Convert dictionary to array
        temperatureInfoPerDay = Array(tempInfoDict.values)
        
        // Sort by date if needed
        temperatureInfoPerDay.sort { $0.date < $1.date }
        
        return temperatureInfoPerDay
    }
}
    


class CurrentListViewModel: ObservableObject{
    @Published var current: CurrentViewModel?
    init(current: Current? = nil) {
        if let current = current {
            self.current = CurrentViewModel(current: current)
        }
    }
    var location: String = ""
    
    func getWeatherCurrent() {
        let apiService = CurrentAPIService.shared
        CLGeocoder().geocodeAddressString(location) { (placemarks, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            if let lat = placemarks?.first?.location?.coordinate.latitude,
               let lon = placemarks?.first?.location?.coordinate.longitude {
                apiService.getJSON(urlString: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&lang=kr&appid=ce878d5130eaace7c56141ff9190f16f&units=metric", dateDecodingStrategy: .secondsSince1970) { (result: Result<Current, CurrentAPIService.APIError>) in
                    switch result {
                    case .success(let current):
                        DispatchQueue.main.async{
                            self.current = CurrentViewModel(current: current)
                        }
                    case .failure(let apiError):
                        switch apiError {
                        case .error(let errorString):
                            print(errorString)
                        }
                    }
                    
                }
            }
        }
    }
}
