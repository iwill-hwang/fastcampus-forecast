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
    var image: UIImage {
        switch self {
        case .sunny:
            return UIImage(named: "clear")!
        case .cloudy:
            return UIImage(named: "cloudy")!
        case .rainy:
            return UIImage(named: "rain")!
        case .snow:
            return UIImage(named: "rain")!
        }
    }
}

class WeatherViewController: UIViewController {
    private var lastUpdated = Date()
    private var lastDeactiveTime: Date?
    
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var iconView: UIImageView!
    @IBOutlet weak private var temperatureLabel: UILabel!
    @IBOutlet weak private var lowHighTemperatureLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.iconView.image = nil
        self.temperatureLabel.text = nil
        self.lowHighTemperatureLabel.text = nil
        
        self.setupRefreshControl()
        self.requestForecast()
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(requestForecast), for: .valueChanged)
        self.scrollView.refreshControl = refreshControl
    }
    
    private func updateForecast(_ data: DailyWeather?) {
        if let data = data {
            self.iconView.image = data.sky.image
            self.temperatureLabel.text = data.temperature.current.asTemperature()
            self.lowHighTemperatureLabel.text = "최저: \(data.temperature.low.asTemperature()) / 최대 \(data.temperature.high.asTemperature())"
        } else {
            self.iconView.image = nil
            self.temperatureLabel.text = "-"
            self.lowHighTemperatureLabel.text = "최저: - / 최대 -"
        }
    }
    
    @objc private func requestForecast() {
        NetworkForecaseUseCase().requestForecast(at: Date()) { [weak self] result in
            switch result {
            case let .success(data):
                self?.updateForecast(data)
            case let .failure(error):
                print(error)
                self?.updateForecast(nil)
            }
            
            self?.scrollView.refreshControl?.endRefreshing()
        }
    }
}
