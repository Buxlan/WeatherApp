//
//  NetworkManager.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/26/21.
//

import Foundation

struct NetworkManager {
    
    static let authKey: String = {
        (Bundle.main.object(forInfoDictionaryKey: "weatherAuthKey") as? String) ?? ""
    }()
}
