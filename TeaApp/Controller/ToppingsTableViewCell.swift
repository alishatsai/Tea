//
//  ToppingsTableViewCell.swift
//  TeaApp
//
//  Created by Alisha on 2021/8/22.
//

import UIKit


class ToppingsTableViewCell: UITableViewCell {
    @IBOutlet weak var addToppingsBtn: UIButton!
    @IBOutlet weak var toppingsNameLabel: UILabel!
    @IBOutlet weak var toppingsPriceLabel: UILabel!
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
