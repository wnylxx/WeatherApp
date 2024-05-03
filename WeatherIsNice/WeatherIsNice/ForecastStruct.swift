//
//  ForecastStruct.swift
//  TestWeatherApp
//
//  Created by wonyoul heo on 5/1/24.
//

import Foundation


////https://api.openweathermap.org/data/2.5/forecast?lat=37.564214&lon=127.001699&appid=ce878d5130eaace7c56141ff9190f16f&units=metric
struct Forecast: Codable {
    struct List: Codable {
        let dt: Date
        struct Main: Codable {
            let temp: Double
            let temp_min: Double
            let temp_max: Double
        }
        let main: Main
        struct Weather: Codable {
            let id: Int
            let description: String
            let icon: String
        }
        let weather: [Weather]
        let dt_txt: String
    }
    let list: [List]
}


//https://api.openweathermap.org/data/2.5/weather?lat=37.564214&lon=127.001699&appid=ce878d5130eaace7c56141ff9190f16f&units=metric

struct Current: Codable {
    let dt: Date
    struct Main: Codable{
        let temp: Double
        let temp_min: Double
        let temp_max: Double
    }
    let main: Main
    struct Weather: Codable{
        let id: Int
        let main: String
        let description:  String
        let icon: String
    }
    let weather: [Weather]
}




//Test
// 참고로 여기서는 print 안되니까 play ground에서 해보세요
