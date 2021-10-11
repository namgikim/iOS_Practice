//
//  TodoInfoSwitchTableViewCell.swift
//  Reminders
//
//  Created by namgi on 2021/09/29.
//

import UIKit

protocol TodoInfoSwitchTableViewCellDelegate {
    func settingSwitchChangedValue(_ sender: TodoInfoSwitchTableViewCell)
}

class TodoInfoSwitchTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    var delegate: TodoInfoSwitchTableViewCellDelegate?
    
    // MARK: - IBOutlets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionSwitch: UISwitch!
    @IBOutlet weak var infoLabel: UILabel!
    
    // MARK: - IBActions
    @IBAction func touchUpActionSwitch(_ sender: UISwitch) {
        delegate?.settingSwitchChangedValue(self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.infoLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
