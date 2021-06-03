//
//  WeatherResponse.swift
//  Forecast
//
//  Created by donghyun on 2021/06/03.
//

import Foundation

struct WeatherResponse: Codable {
    struct Header: Codable {
        let code: String
        let message: String
    }
    
    struct Body: Codable {
        let type: String
        let items: [Item]
    }
    
    struct Item: Codable {
        let date: String
        let time: String
        let category: String
        let x: Int
        let y: Int
    }
    
    let header: Header
    let body: Body
}
