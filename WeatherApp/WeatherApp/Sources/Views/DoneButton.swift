//
//  DoneButton.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/28/21.
//

import UIKit

class DoneButton: UIButton {
    
    init() {
        super.init(frame: .zero)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
        configureUI()
    }
    
    func configureUI() {
        self.setTitle("Готово", for: .normal)
        self.setTitleColor(.black, for: .normal)
        self.contentMode = .scaleAspectFit
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentHorizontalAlignment = .center
        self.contentEdgeInsets = .init(top: 8, left: 24, bottom: 8, right: 24)
        self.layer.cornerRadius = 16
        self.clipsToBounds = true
        self.backgroundColor = Asset.accent2.color
    }
    
}

