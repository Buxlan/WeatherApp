//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/22/21.
//

import Network
import UIKit
import CoreData

struct TempData: Decodable {
    var day: Float
    var min: Float
    var max: Float
    var night: Float
    var eve: Float
    var morn: Float
}

struct DailyWeather: Decodable {
    
    enum CodingKeys: CodingKey {
        case dt
        case temp
    }
    
    var dt: Date
    var temp: TempData
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dt = try container.decode(Int.self, forKey: .dt)
        let timeInterval = TimeInterval(dt)
        self.dt = Date(timeIntervalSince1970: timeInterval)
        self.temp = try container.decode(TempData.self, forKey: .temp)
    }
    
    init() {
        self.dt = Date()
        self.temp = TempData(day: 0, min: 0, max: 0, night: 0, eve: 0, morn: 0)
    }
    
}

struct DailyWeatherList: Decodable {
    var daily: [DailyWeather]
}

class DailyWeatherManager: NSObject {
    
    static let shared = DailyWeatherManager()
    private var observers: [Observer] = [Observer]()
        
    private lazy var session: URLSession = {
        URLSession.shared
    }()
    
    // MARK: - Init
    
    override init() {
        
    }
    
    deinit {
        removeAllObservers()
    }
    
    // MARK: - Helper functions
    
    private func prepareDailyWeatherRequest(city: City) -> URLRequest? {
        let authKey = NetworkManager.authKey
        let coordLatitude = city.coord.latitude
        let coordLongitude = city.coord.longitude
        let urlString =
            "https://api.openweathermap.org/data/2.5/onecall?lat=\(coordLatitude)&lon=\(coordLongitude)&exclude=current,minutely,hourly,alerts&units=metric&appid=\(authKey)"
//        print(urlString)
        guard let url = URL(string: urlString) else {
            print("Invalid url")
            return nil
        }
        let request = URLRequest(url: url)
        return request
    }   
        
    func updateDailyWeather(at city: City,
                             completionHandler: @escaping ((DailyWeatherList) -> Void)) {
        guard let request = prepareDailyWeatherRequest(city: city) else {
            return
        }
        let handler: ((Data?, URLResponse?, Error?) -> Void) = { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let decodedList = try decoder.decode(DailyWeatherList.self, from: data)
                    completionHandler(decodedList)
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
        let task = session.dataTask(with: request,
                                    completionHandler: handler)
        task.resume()
    }
    
    func addObserver(_ observer: Observer) {
        observers.append(observer)
    }
    
    func removeObserver(_ observer: Observer) {
        if let index = observers.firstIndex(where: { $0 === observer }) {
            observers.remove(at: index)
        }
    }
    
    private func removeAllObservers() {
        observers.removeAll()
    }
    
}

extension DailyWeatherManager {
    var authKey: String {
        (Bundle.main.object(forInfoDictionaryKey: "weatherAuthKey") as? String) ?? ""
    }
}

//let currentWeather = try decoder.decode(CurrentWeather.self, from: data)
//switch context {
//case CoreDataManager.shared.privateObjectContext:
//    currentWeather.choosedCity = city
//default:
//    let newContext = CoreDataManager.shared.privateObjectContext
//    if let cityNew = try newContext.existingObject(with: city.objectID) as? City {
//        currentWeather.choosedCity = cityNew
//    }
//}
//CoreDataManager.shared.save(context)
