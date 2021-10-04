//
//  MainViewTableCell.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/24/21.
//

import UIKit

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
    
    // MARK: - Helper methods
    func configure(data: DataModel) {
        textLabel?.text = data.text
        detailTextLabel?.text = data.detailText
    }
}
