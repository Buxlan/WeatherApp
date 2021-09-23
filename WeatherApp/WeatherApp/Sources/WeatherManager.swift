//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/22/21.
//

import Network
import UIKit

class WeatherManager: NSObject {
    
    static let shared = WeatherManager()
        
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        return session
    }()
    
    func updateWeather(cities: [City]) {
        DispatchQueue.global(qos: .utility).async {
            for city in cities {
                self.updateCityWeather(city)
            }
        }
    }
    
    func updateCityWeather(_ city: City) {
        let id = city.id
        let urlString = "https://api.openweathermap.org/data/2.5/weather?id=\(id)&appid=7097b7d0449c11e0933f4a5d2dfd47da&units=metric"
        print(urlString)
        guard let url = URL(string: urlString) else {
            return
        }
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { [weak city] (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let currentWeather = try decoder.decode(CurrentWeather.self, from: data)
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
                    
            }
        }
        task.resume()
    }
    
}
//
//extension WeatherManager: URLSessionDataDelegate {
//
//    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
//
//    }
//
//
//}
