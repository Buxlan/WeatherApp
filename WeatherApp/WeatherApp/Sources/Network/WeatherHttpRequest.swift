//
//  WeatherHttpRequest.swift
//  WeatherApp
//
//  Created by  Buxlan on 10/3/21.
//

import UIKit

class WeatherHttpRequest {
    
    // MARK: - Properties
    var city: City
    
    private lazy var session: URLSession = {
        URLSession.shared
    }()
    
    private func prepareRequest() -> URLRequest? {
        let urlString =
            "https://api.openweathermap.org/data/2.5/onecall?lat=\(city.coordLatitude)&lon=\(city.coordLongitude)&exclude=minutely,hourly,alerts&units=metric&appid=\(authKey)"
        guard let url = URL(string: urlString) else {
            print("Invalid url")
            return nil
        }
        let request = URLRequest(url: url)
        return request
    }
    var task: URLSessionTask?
    
    private let authKey = NetworkManager.authKey
    private var completionHandler: ((City, DailyWeatherList) -> Void)?
    private lazy var handler: ((Data?, URLResponse?, Error?) -> Void) = { (data, _, error) in
        if let error = error {
            print(error.localizedDescription)
            return
        }
        guard let data = data else {
            print("Error HTTP request: no data")
            return
        }
//        print(String(data: data, encoding: .utf8))
        let decoder = JSONDecoder()
        do {
            let decodedList = try decoder.decode(DailyWeatherList.self, from: data)
            self.completionHandler?(self.city, decodedList)
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context) {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
        self.task = nil
    }
    
    // MARK: - Init
    
    init(city: City) {
        self.city = city
    }
    
    // MARK: - Helper functions
    
    func fetchRequest(completionHandler: @escaping ((City, DailyWeatherList) -> Void)) {
        guard let request = self.prepareRequest() else {
            return
        }
        self.completionHandler = completionHandler
        task = session.dataTask(with: request,
                                completionHandler: handler)
        task?.resume()
    }
    
}
