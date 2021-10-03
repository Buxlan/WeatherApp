//
//  LoadingButton.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/30/21.
//

import UIKit

class LoadingButton: ShadowButton {
    
    // MARK: - Properties
    
    private var originalButtonText: String?
    private var originalImage: UIImage?
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.color = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = .black
        return view
    }()
    
    // MARK: - Init
    
    init() {
        super.init(title: originalButtonText, image: originalImage)
        self.addSubview(activityIndicator)
        centerActivityIndicator()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimating() {
        self.originalButtonText = self.titleLabel?.text
        self.originalImage = self.image(for: .normal)
        self.setTitle("", for: .normal)
        self.setImage(nil, for: .normal)
        self.showSpinning()
    }
    
    // MARK: - Helper methods
    
    func stopAnimating() {
        self.setTitle(self.originalButtonText, for: .normal)
        self.setImage(self.originalImage, for: .normal)
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        self.imageView?.isHidden = false
    }
    
    private func showSpinning() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func centerActivityIndicator() {
        let xCenterConstraint = NSLayoutConstraint(item: self,
                                                   attribute: .centerX,
                                                   relatedBy: .equal,
                                                   toItem: activityIndicator,
                                                   attribute: .centerX,
                                                   multiplier: 1, constant: 0)
        self.addConstraint(xCenterConstraint)
        
        let yCenterConstraint = NSLayoutConstraint(item: self,
                                                   attribute: .centerY,
                                                   relatedBy: .equal,
                                                   toItem: activityIndicator,
                                                   attribute: .centerY,
                                                   multiplier: 1,
                                                   constant: 0)
        self.addConstraint(yCenterConstraint)
    }
}
