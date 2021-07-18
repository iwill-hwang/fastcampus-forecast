//
//  WeatherResponse.swift
//  Forecast
//
//  Created by donghyun on 2021/06/03.
//

import Foundation

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
    
    enum CodingKeys : String, CodingKey{
        case type = "dataType"
        case items
    }
}

struct Items: Codable {
    let list: [Item]
    
    enum CodingKeys : String, CodingKey{
        case list = "item"
    }
}

struct Item: Codable {
    let date: String
    let forecastTime: String
    let baseTime: String
    let category: String
    let x: Int
    let y: Int
    let value: String
    
    enum CodingKeys : String, CodingKey {
        case date           = "baseDate"
        case baseTime       = "baseTime"
        case forecastTime   = "fcstTime"
        case category       = "category"
        case x              = "nx"
        case y              = "ny"
        case value          = "fcstValue"
    }
}

struct Response: Codable {
    let header: Header
    let body: Body
}

struct APIResult: Codable {
    let response: Response
}
