//
//  SubtitleTableViewCell.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/22/21.
//

import UIKit

class SubtitleTableViewCell: UITableViewCell, Configurable {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isSelected = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        let color = UIColor.gray
        if selected {
            self.backgroundColor = color
        } else {
            self.backgroundColor = .white
        }
    }
    
    // MARK: - Helper methods
    func configure(data: MainDataModel) {
        textLabel?.text = data.text
        detailTextLabel?.text = data.detailText
    }
    
}
