//
//  ForecastUseCase.swift
//  Forecast
//
//  Created by donghyun on 2021/07/19.
//

import Foundation

protocol ForecastUseCase {
    func requestForecast(at date: Date, completion: @escaping ((Result<DailyWeather, Error>) -> Void))
}
