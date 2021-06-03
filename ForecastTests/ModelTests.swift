//
//  ModelTests.swift
//  ForecastTests
//
//  Created by donghyun on 2021/06/03.
//

import XCTest

private let mock = """
    {"response":{"header":{"resultCode":"00","resultMsg":"NORMAL_SERVICE"},"body":{"dataType":"JSON","items":{"item":[{"baseDate":"20210603","baseTime":"0500","category":"POP","fcstDate":"20210603","fcstTime":"0900","fcstValue":"60","nx":1,"ny":1},{"baseDate":"20210603","baseTime":"0500","category":"PTY","fcstDate":"20210603","fcstTime":"0900","fcstValue":"1","nx":1,"ny":1},{"baseDate":"20210603","baseTime":"0500","category":"REH","fcstDate":"20210603","fcstTime":"0900","fcstValue":"100","nx":1,"ny":1},{"baseDate":"20210603","baseTime":"0500","category":"SKY","fcstDate":"20210603","fcstTime":"0900","fcstValue":"4","nx":1,"ny":1},{"baseDate":"20210603","baseTime":"0500","category":"T3H","fcstDate":"20210603","fcstTime":"0900","fcstValue":"20","nx":1,"ny":1},{"baseDate":"20210603","baseTime":"0500","category":"UUU","fcstDate":"20210603","fcstTime":"0900","fcstValue":"4","nx":1,"ny":1},{"baseDate":"20210603","baseTime":"0500","category":"VEC","fcstDate":"20210603","fcstTime":"0900","fcstValue":"249","nx":1,"ny":1},{"baseDate":"20210603","baseTime":"0500","category":"VVV","fcstDate":"20210603","fcstTime":"0900","fcstValue":"1.5","nx":1,"ny":1},{"baseDate":"20210603","baseTime":"0500","category":"WSD","fcstDate":"20210603","fcstTime":"0900","fcstValue":"4.3","nx":1,"ny":1},{"baseDate":"20210603","baseTime":"0500","category":"WAV","fcstDate":"20210603","fcstTime":"0900","fcstValue":"1.5","nx":1,"ny":1}]},"pageNo":1,"numOfRows":10,"totalCount":247}}}
    """
class ModelTests: XCTestCase {
    func test_날씨_데이터() {
        do {
            let data = mock.data(using: .utf8)!
            let response = try JSONDecoder().decode(WeatherResponse.self, from: data)
            XCTAssertNotNil(response)
        } catch {
            print(error)
        }
    }
}
