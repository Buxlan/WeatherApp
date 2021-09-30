//
//  AddCityButton.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/28/21.
//

import UIKit

class AddCityButton: ShadowButton {
    
    init() {
        let image = Asset.plus.image
        super.init(title: nil, image: image)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        self.translatesAutoresizingMaskIntoConstraints = false
        imageView?.contentMode = .scaleAspectFit
        backgroundColor = Asset.accent2.color
        layer.cornerRadius = 16
        contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
    }
    
}
