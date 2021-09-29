//
//  MainDataModel.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/28/21.
//

import Foundation

protocol DataModel {
    var text: String { get }
    var detailText: String? { get }
    init(text: String, detailText: String?)
}

struct MainDataModel: DataModel {
    var text: String
    var detailText: String?
    
    init(text: String, detailText: String?) {
        self.text = text
        self.detailText = detailText
    }
}
