//
//  NetworkUseCase.swift
//  Forecast
//
//  Created by donghyun on 2021/06/04.
//

import Foundation

extension ForecastData {
    init(result: APIResult, now: Date) {
        let list = result.response.body.items.list
        
        let low = list.filter{$0.category == "T3H"}.compactMap{Double($0.value)}.min() ?? 0
        let high = list.filter{$0.category == "T3H"}.compactMap{Double($0.value)}.max() ?? 0
        
        let skyValue = Int(list.first(where: {$0.category == "SKY"})?.value ?? "0")!
        let ptyValue = Int(list.first(where: {$0.category == "PTY"})?.value ?? "0")!
        
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
        
        let current = list.first(where: {$0.category == "T3H" && $0.forecastTime == targetHour})?.value ?? "0"
        
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
        self.temperature = DayTemperature(current: Double(current)!, low: low, high: high)
    }
}

enum ForecastError: Error {
    case malformedData
}

protocol ForecastUseCase {
    func requestForecast(at date: Date, completion: @escaping ((Result<ForecastData, Error>) -> Void))
}


extension DateFormatter {
    convenience init(format: String) {
        self.init()
        self.dateFormat = format
    }
}

final class NetworkForecaseUseCase: ForecastUseCase {
    func requestForecast(at date: Date, completion: @escaping ((Result<ForecastData, Error>) -> Void)) {
        let dateFormatter = DateFormatter(format: "yyyyMMdd")
        let timeFormatter = DateFormatter(format: "HHmm")
        
        var components = URLComponents(string: "http://apis.data.go.kr/1360000/VilageFcstInfoService/getVilageFcst")
        components?.queryItems = [
            URLQueryItem(name: "serviceKey", value: "tu7VcXh35d2PIVr4/qm7o/urWRwn5CVV1lpgu4zReoNWQeWY6PA3fU8SEiWQ1ZUmDovuh86X1t7vX/WCRx46zQ=="),
            URLQueryItem(name: "dataType", value: "json"),
            URLQueryItem(name: "base_date", value: dateFormatter.string(from: date)),
            URLQueryItem(name: "base_time", value: "0500"),
            URLQueryItem(name: "nx", value: "1"),
            URLQueryItem(name: "ny", value: "1"),
            URLQueryItem(name: "numOfRows", value: "55")
        ]
        
        var request = URLRequest(url: (components?.url)!)
        
        request.httpMethod = "GET"
        
        print(request.url)
        
        URLSession.shared.dataTask(with: request) { data, res, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(ForecastError.malformedData))
                }
                return
            }
            
            do {
                let result = try JSONDecoder().decode(APIResult.self, from: data)
                DispatchQueue.main.async {
                    
                    completion(.success(ForecastData(result: result, now: Date())))
                }
            } catch{
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
