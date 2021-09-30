//
//  Layers.swift
//  Places
//
//  Created by  Buxlan on 7/19/21.
//

import UIKit

class ShadowLayer: CALayer {
    
    override init() {
        super.init()
        configureMask()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        configureMask()
    }
    
    private func configureMask() {
        shadowRadius = 8
        shadowOpacity = 0.6
        shadowOffset = CGSize(width: 3, height: 3)
        shadowColor = Asset.other0.color.cgColor
        masksToBounds = false
        cornerRadius = shadowRadius
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        shadowPath = UIBezierPath(rect: bounds).cgPath
    }
    
}
