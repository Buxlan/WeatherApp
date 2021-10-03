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
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 132))
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addBottomBorder()
    }
    
    // MARK: - Helper methods
    
    func configure(data: DataModel) {
        cityNameLabel.text = data.text
        temperatureLabel.text = data.detailText
    }
    
    private func configureUI() {
        addSubview(cityNameLabel)
        addSubview(temperatureLabel)
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 1
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        self.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                          y: bounds.maxY - layer.shadowRadius,
                                                          width: bounds.width,
                                                          height: layer.shadowRadius)).cgPath
        configureConstraints()
    }
    
    private func configureConstraints() {
        let constraints: [NSLayoutConstraint] = [
            cityNameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            cityNameLabel.widthAnchor.constraint(equalTo: self.widthAnchor),
            cityNameLabel.topAnchor.constraint(equalTo: self.topAnchor),
            cityNameLabel.bottomAnchor.constraint(equalTo: temperatureLabel.topAnchor, constant: -16),
            
            temperatureLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            temperatureLabel.widthAnchor.constraint(equalTo: self.widthAnchor),
            temperatureLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func addBottomBorder() {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0.0, y: self.bounds.size.height-1, width: self.bounds.width, height: 1.0)
        bottomBorder.backgroundColor = Asset.accent2.color.cgColor
        self.layer.addSublayer(bottomBorder)
    }
    
}
