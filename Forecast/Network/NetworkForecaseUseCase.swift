//
//  NetworkUseCase.swift
//  Forecast
//
//  Created by donghyun on 2021/06/04.
//

import Foundation

enum NetworkError: Error {
    case dataNotExists
}

extension DateFormatter {
    convenience init(format: String) {
        self.init()
        self.dateFormat = format
    }
}

final class NetworkForecaseUseCase: ForecastUseCase {
    private var serviceKey = ""
    
    func requestForecast(at date: Date, completion: @escaping ((Result<DailyWeather, Error>) -> Void)) {
        let dateFormatter = DateFormatter(format: "yyyyMMdd")
        var components = URLComponents(string: "http://apis.data.go.kr/1360000/VilageFcstInfoService/getVilageFcst")
        
        if serviceKey.isEmpty {
            assertionFailure("공공 데이터 포털(https://www.data.go.kr/) 에 가입한 후 serviceKey 를 입력하셔야 합니다. 자세한 내용은 강의를 참고해주세요!")
        }
        
        components?.queryItems = [
            URLQueryItem(name: "serviceKey", value: serviceKey),
            URLQueryItem(name: "dataType", value: "json"),
            URLQueryItem(name: "base_date", value: dateFormatter.string(from: date)),
            URLQueryItem(name: "base_time", value: "0200"),
            URLQueryItem(name: "nx", value: "1"),
            URLQueryItem(name: "ny", value: "1"),
            URLQueryItem(name: "numOfRows", value: "100")
        ]
        
        var request = URLRequest(url: (components?.url)!)
        
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        
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
                let weather = try DailyWeather(result: result, now: date)
                
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
