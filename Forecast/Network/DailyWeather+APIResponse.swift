//
//  DailyWeather+APIResponse.swift
//  Forecast
//
//  Created by donghyun on 2021/07/19.
//

import Foundation

enum DailyWeatherError: Error {
    case invalidTemperature(message: String)
}

extension DailyWeather {
    init(result: APIResult, now: Date) throws {
        let list = result.response.body.items.list
        let dateString = DateFormatter(format: "yyyyMMdd").string(from: now)
        
        guard let tmx = list.first(where: {$0.category == "TMX" && dateString == $0.forecastDate})?.value,
              let high = Double(tmx),
              let tmn = list.first(where :{$0.category == "TMN" && dateString == $0.forecastDate})?.value,
              let low = Double(tmn) else {
            throw DailyWeatherError.invalidTemperature(message: "최저기온과 최고 기온 데이터를 가져올 수 없습니다")
        }
        
        guard let skyInfo = list.first(where: {$0.category == "SKY"})?.value,
              let skyValue = Int(skyInfo),
              let ptyInfo = list.first(where: {$0.category == "PTY"})?.value,
              let ptyValue = Int(ptyInfo)
              else {
            throw DailyWeatherError.invalidTemperature(message: "현재 하늘 상태 정보를 가져올 수 없습니다.")
        }
        
        let sky: Sky
        
        let formatter = DateFormatter(format: "HH")
        let hour = Int(formatter.string(from: now))!
        let targetHour: String
        
        switch hour {
        case 0...9:
            targetHour = "0900"
        case 10...12:
            targetHour = "1200"
        case 13...15:
            targetHour = "1500"
        case 16...18:
            targetHour = "1800"
        default:
            targetHour = "2100"
        }
        
        guard let current = list.first(where: {$0.category == "T3H" && $0.forecastTime == targetHour})?.value else {
            throw DailyWeatherError.invalidTemperature(message: "현재 온도 정보를 가져올수 없습니다.")
        }
        
        switch ptyValue {
        case 1, 2, 4:
            sky = .rainy
        case 3:
            sky = .snow
        default:
            if skyValue == 3 || skyValue == 4 {
                sky = .cloudy
            } else {
                sky = .sunny
            }
        }
        
        self.sky = sky
        self.temperature = DailyTemperature(current: Double(current)!, low: low, high: high)
    }
}
