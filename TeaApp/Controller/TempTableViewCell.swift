//
//  TempTableViewCell.swift
//  TeaApp
//
//  Created by Alisha on 2021/8/22.
//

import UIKit

protocol TempTableViewCellDelegate: AnyObject {
    func toggleTempSegmentedCtrl(with index: Int)
    
}

class TempTableViewCell: UITableViewCell {

    weak var delegate: TempTableViewCellDelegate?
    
    @IBOutlet weak var tempSegmentedControl: UISegmentedControl!
    
    private var index: Int? {
        return tempSegmentedControl.selectedSegmentIndex
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func toggleTempSegmentedCtrl(_ sender: Any) {
        delegate?.toggleTempSegmentedCtrl(with: index!)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
