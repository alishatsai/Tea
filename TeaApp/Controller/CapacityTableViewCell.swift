//
//  CapacityTableViewCell.swift
//  TeaApp
//
//  Created by Alisha on 2021/8/22.
//

import UIKit


protocol CapacityTableViewCellDelegate: AnyObject {
    func toggleCapacitySegmentedCtrl(with index: Int)
    
}


class CapacityTableViewCell: UITableViewCell {

    weak var delegate: CapacityTableViewCellDelegate?
    
    @IBOutlet weak var capacitySegmentedControl: UISegmentedControl!
    
    
    private var index: Int? {
        return capacitySegmentedControl.selectedSegmentIndex
    }

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func toggleCapacitySegmentedCtrl(_ sender: Any) {
        

        delegate?.toggleCapacitySegmentedCtrl(with: index!)
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
