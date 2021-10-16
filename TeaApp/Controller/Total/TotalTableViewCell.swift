//
//  TotalTableViewCell.swift
//  TeaApp
//
//  Created by Alisha on 2021/8/21.
//

import UIKit

class TotalTableViewCell: UITableViewCell {

    @IBOutlet weak var drinkImageView: UIImageView!
    @IBOutlet weak var ordererNameLabel: UILabel!
    @IBOutlet weak var drinkNameLabel: UILabel!
    @IBOutlet weak var capacityLabel: UILabel!
    @IBOutlet weak var tempLevelLabel: UILabel!
    @IBOutlet weak var sugarLevelLabel: UILabel!
    @IBOutlet weak var toppingsLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var subtotalLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
