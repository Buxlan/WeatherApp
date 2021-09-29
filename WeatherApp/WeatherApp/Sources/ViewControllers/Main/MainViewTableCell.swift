//
//  MainViewTableCell.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/24/21.
//

import UIKit



//struct CellWeatherDataModel: DataModel {
//    var text: String
//    var detailText: String
//
//    init(city: City) {
//        text = city.name
//        let weather = city.currentWeather?.temp ?? 0.0
//        detailText = "\(weather)"
//    }
//
//    init(dailyWeather: DailyWeather) {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd/MM/YY"
//        text = dateFormatter.string(from: dailyWeather.dt)
//        detailText = "\(dailyWeather.temp.day)"
//    }
//}

protocol Configurable {
    static var reuseIdentifier: String { get }
    func configure(data: MainDataModel)
}
extension Configurable {
    static var reuseIdentifier: String { String(describing: Self.self) }
}

class MainViewTableCell: UITableViewCell, Configurable {
//
//    private lazy var tempLabel: UILabel = {
//        let view = UILabel()
//        view.accessibilityIdentifier = "typeLabel (table cell)"
//        view.textColor = .black
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.textAlignment = .center
//        return view
//    }()
    
    required convenience init() {
        self.init(style: .value1, reuseIdentifier: Self.reuseIdentifier)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helper functions
    func configure(data: MainDataModel) {
        textLabel?.text = data.text
        detailTextLabel?.text = data.detailText
    }
}
