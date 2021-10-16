//
//  SugarTableViewCell.swift
//  TeaApp
//
//  Created by Alisha on 2021/8/22.
//

import UIKit

protocol SugarTableViewCellDelegate: AnyObject {
    func toggleSugarSegmentedCtrl(with index: Int)
    
}



class SugarTableViewCell: UITableViewCell {

    weak var delegate: SugarTableViewCellDelegate?
    
    @IBOutlet weak var sugarSegmentedControl: UISegmentedControl!
    
    private var index: Int? {
        return sugarSegmentedControl.selectedSegmentIndex
    }

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func toggleSugarSegmentedCtrl(_ sender: Any) {
        delegate?.toggleSugarSegmentedCtrl(with: index!)
    }

    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
