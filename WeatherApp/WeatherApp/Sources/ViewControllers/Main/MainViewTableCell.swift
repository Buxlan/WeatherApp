//
//  MainViewTableCell.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/24/21.
//

import UIKit

protocol ConfigurableCell {
    func configure(city: ChoosedCity)
}

class MainViewTableCell: UITableViewCell, ConfigurableCell {
//
//    private lazy var tempLabel: UILabel = {
//        let view = UILabel()
//        view.accessibilityIdentifier = "typeLabel (table cell)"
//        view.textColor = .black
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.textAlignment = .center
//        return view
//    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(city: ChoosedCity) {
        textLabel?.text = "\(city.name)"
        detailTextLabel?.text = String(city.currentWeather?.temp ?? 0.0)        
    }
}
