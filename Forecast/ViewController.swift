//
//  ViewController.swift
//  Forecast
//
//  Created by donghyun on 2021/06/03.
//

import UIKit

extension Double{
    func asTemperature() -> String {
        return floor(self) == self ? "\(Int(self))" : "\(self)"
    }
}

extension Sky {
    var emoji: String {
        switch self {
        case .sunny:
            return "☀️"
        case .cloudy:
            return "☁️"
        case .rainy:
            return "🌧"
        case .snow:
            return "❄️"
        }
    }
}

class ViewController: UIViewController {
    private var lastUpdated = Date()
    
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var skyLabel: UILabel!
    @IBOutlet weak private var temperatureLabel: UILabel!
    @IBOutlet weak private var lowHighTemperatureLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupRefreshControl()
        self.requestForecast()
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(requestForecast), for: .valueChanged)
        self.scrollView.refreshControl = refreshControl
    }
    
    private func updateForecast(_ data: ForecastData) {
        self.skyLabel.text = data.sky.emoji
        self.temperatureLabel.text = data.temperature.current.asTemperature()
        self.lowHighTemperatureLabel.text = "최저: \(data.temperature.low.asTemperature()) / 최대 \(data.temperature.high.asTemperature())"
    }
    
    @objc private func requestForecast() {
        NetworkForecaseUseCase().requestForecast(at: Date()) { [weak self] result in
            switch result {
            case let .success(data):
                self?.updateForecast(data)
            case let .failure(error):
                print(error)
            }
            self?.scrollView.refreshControl?.endRefreshing()
        }
    }
}
