//
//  DoneButton.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/28/21.
//

import UIKit

class DoneButton: ShadowButton {
    
    init() {
        super.init(title: L10n.Controls.done, image: nil)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(title: L10n.Controls.done, image: nil)
        configureUI()
    }
    
    func configureUI() {
        self.setTitleColor(.black, for: .normal)
        self.contentMode = .scaleAspectFit
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentHorizontalAlignment = .center
        self.contentEdgeInsets = .init(top: 8, left: 24, bottom: 8, right: 24)
        self.layer.cornerRadius = 16
        self.backgroundColor = Asset.accent2.color
    }
    
}
