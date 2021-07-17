//
//  Forecast.swift
//  Forecast
//
//  Created by donghyun on 2021/06/04.
//

import Foundation

enum Sky {
    case sunny
    case cloudy
    case rainy
    case snow
}

struct DailyTemperature {
    let current: Double
    let low: Double
    let high: Double
}

struct DailyWeather {
    let temperature: DailyTemperature
    let sky: Sky
}
