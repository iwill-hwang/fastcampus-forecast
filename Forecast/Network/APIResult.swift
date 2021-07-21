//
//  WeatherResponse.swift
//  Forecast
//
//  Created by donghyun on 2021/06/03.
//

import Foundation

struct APIResult: Codable {
    let response: Response
}

struct Response: Codable {
    let header: Header
    let body: Body
}

extension Response {
    struct Header: Codable {
        let code: String
        let message: String
        
        enum CodingKeys : String, CodingKey{
            case code = "resultCode"
            case message = "resultMsg"
        }
    }
    
    struct Body: Codable {
        let type: String
        let items: Items
        let pageNo: Int
        let numberOfRows: Int
        let totalCount: Int
        
        enum CodingKeys : String, CodingKey{
            case type = "dataType"
            case items
            case pageNo
            case numberOfRows = "numOfRows"
            case totalCount
        }
    }
}

extension Response.Body {
    struct Items: Codable {
        let list: [Item]
        
        enum CodingKeys : String, CodingKey{
            case list = "item"
        }
    }

    struct Item: Codable {
        let date: String
        let forecastTime: String
        let forecastDate: String
        let baseTime: String
        let category: String
        let x: Int
        let y: Int
        let value: String
        
        enum CodingKeys : String, CodingKey {
            case date           = "baseDate"
            case baseTime       = "baseTime"
            case forecastTime   = "fcstTime"
            case forecastDate   = "fcstDate"
            case category       = "category"
            case x              = "nx"
            case y              = "ny"
            case value          = "fcstValue"
        }
    }
}
