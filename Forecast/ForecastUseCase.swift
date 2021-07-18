//
//  NetworkUseCase.swift
//  Forecast
//
//  Created by donghyun on 2021/06/04.
//

import Foundation

enum DailyWeatherError: Error {
    case invalidTemperature(message: String)
}

enum NetworkError: Error {
    case dataNotExists
}

extension DailyWeather {
    init(result: APIResult, now: Date) throws {
        let list = result.response.body.items.list
        
        guard let tmx = list.first(where: {$0.category == "TMX"})?.value, let high = Double(tmx), let tmn = list.first(where :{$0.category == "TMN"})?.value, let low = Double(tmn) else {
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

protocol ForecastUseCase {
    func requestForecast(at date: Date, completion: @escaping ((Result<DailyWeather, Error>) -> Void))
}

extension DateFormatter {
    convenience init(format: String) {
        self.init()
        self.dateFormat = format
    }
}

final class NetworkForecaseUseCase: ForecastUseCase {
    func requestForecast(at date: Date, completion: @escaping ((Result<DailyWeather, Error>) -> Void)) {
        let dateFormatter = DateFormatter(format: "yyyyMMdd")
        var components = URLComponents(string: "http://apis.data.go.kr/1360000/VilageFcstInfoService/getVilageFcst")
        
        components?.queryItems = [
            URLQueryItem(name: "serviceKey", value: "tu7VcXh35d2PIVr4/qm7o/urWRwn5CVV1lpgu4zReoNWQeWY6PA3fU8SEiWQ1ZUmDovuh86X1t7vX/WCRx46zQ=="),
            URLQueryItem(name: "dataType", value: "json"),
            URLQueryItem(name: "base_date", value: dateFormatter.string(from: date)),
            URLQueryItem(name: "base_time", value: "0200"),
            URLQueryItem(name: "nx", value: "1"),
            URLQueryItem(name: "ny", value: "1"),
            URLQueryItem(name: "numOfRows", value: "100")
        ]
        
        var request = URLRequest(url: (components?.url)!)
        
        request.httpMethod = "GET"
        request.timeoutInterval = 5
        
        if let url = components?.url {
            print(url.absoluteString)
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.dataNotExists))
                }
                return
            }
            
            do {
                let result = try JSONDecoder().decode(APIResult.self, from: data)
                let weather = try DailyWeather(result: result, now: Date())
                
                DispatchQueue.main.async {
                    completion(.success(weather))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}
