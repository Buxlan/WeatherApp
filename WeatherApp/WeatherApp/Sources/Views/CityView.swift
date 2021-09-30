//
//  CityView.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/27/21.
//

import UIKit

class CityView: UIView, Configurable {
    
    // MARK: - Properties
    private lazy var cityNameLabel: UILabel = {
        let view = UILabel()
        view.accessibilityIdentifier = "cityNameLabel"
        view.textColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        view.font = .preferredFont(forTextStyle: .largeTitle)
        view.numberOfLines = 1
        return view
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let view = UILabel()
        view.accessibilityIdentifier = "temperatureLabel"
        view.textColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        view.font = .preferredFont(forTextStyle: .largeTitle)
        view.numberOfLines = 1
        return view
    }()
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helper functions
    
    func configure(data: MainDataModel) {
        cityNameLabel.text = data.text
        temperatureLabel.text = L10n.Weather.current + ": " + (data.detailText ?? "--??--") + " " + L10n.Weather.units
    }
    
    private func configureUI() {
        addSubview(cityNameLabel)
        addSubview(temperatureLabel)
        configureConstraints()
    }
    
    private func configureConstraints() {
        let constraints: [NSLayoutConstraint] = [
            cityNameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            cityNameLabel.widthAnchor.constraint(equalTo: self.widthAnchor),
            cityNameLabel.topAnchor.constraint(equalTo: self.topAnchor),
            cityNameLabel.heightAnchor.constraint(equalToConstant: 60),
            cityNameLabel.bottomAnchor.constraint(equalTo: temperatureLabel.topAnchor, constant: -16),
            
            temperatureLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            temperatureLabel.widthAnchor.constraint(equalTo: self.widthAnchor),
            temperatureLabel.heightAnchor.constraint(equalToConstant: 60),
            temperatureLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
}
