
//
//  HistoryTableViewCell.swift
//  GlutenFreeFinder
//
//  Created by Nigel Krajewski on 1/22/21.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // Override imageView size
    override func layoutSubviews() {
        
        // Call super for layoutSubviews
        super.layoutSubviews()
        backgroundColor = .clear
        backgroundView = UIImageView(image: UIImage(named: "tableViewBackground"))
        backgroundView?.frame =  CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        
        // Set imageView properties to crop image within set frame
        imageView?.frame = CGRect(x: 25, y: frame.height/2 - 30, width: 60, height: 60)
        imageView?.layer.cornerRadius = 3
        imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        imageView?.clipsToBounds = true

        // Set text positions
        textLabel?.font = textLabel?.font.withSize(56)
        textLabel?.frame = CGRect(x: 90, y: 10, width: frame.width * 0.65, height: 30)
        textLabel?.adjustsFontSizeToFitWidth = true
        textLabel?.minimumScaleFactor = 0.25
        textLabel?.numberOfLines = 2
        
        detailTextLabel?.frame = CGRect(x: 90, y: 45, width: frame.width * 0.65, height: 15)

        // Add accessory
        accessoryType = .detailButton
    }
}
