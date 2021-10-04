//
//  TitleView.swift
//  WeatherApp
//
//  Created by  Buxlan on 10/4/21.
//

import UIKit

class TitleView: UIView, Configurable {
    
    // MARK: - Properties
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.accessibilityIdentifier = "cityNameLabel"
        view.textColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .left
        view.font = .preferredFont(forTextStyle: .largeTitle)
        view.numberOfLines = 1
        return view
    }()
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 200))
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addBottomBorder()
    }
    
    // MARK: - Helper methods
    
    func configure(data: DataModel) {
        titleLabel.text = data.text
    }
    
    private func configureUI() {
        addSubview(titleLabel)
        self.backgroundColor = Asset.accent2.color
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
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            titleLabel.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -64),
            titleLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 100),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)
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
