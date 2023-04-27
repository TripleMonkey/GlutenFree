
//
//  CheckListTableViewCell.swift
//  GlutenFreeFinder
//
//  Created by Nigel Krajewski on 1/26/21.
//

import UIKit

class CheckListTableViewCell: UITableViewCell {

    @IBOutlet weak var checkListView: CheckListView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
