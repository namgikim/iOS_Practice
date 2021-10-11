//
//  TodoInfoTimeTableViewCell.swift
//  Reminders
//
//  Created by namgi on 2021/10/01.
//

import UIKit

protocol TodoInfoTimeTableViewCellDelegate {
    func valueChangedDatePicker(_ sender: TodoInfoTimeTableViewCell)
}

class TodoInfoTimeTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    var delegate: TodoInfoTimeTableViewCellDelegate?
    
    // MARK: - IBOutlets
    @IBOutlet weak var timeDatePicker: UIDatePicker!

    // MARK: - IBActions
    @IBAction func touchUpTimeDatePicker(_ sender: UIDatePicker) {
        delegate?.valueChangedDatePicker(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.timeDatePicker.preferredDatePickerStyle = .inline
//        self.timeDatePicker.locale = Locale(identifier: "ko")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
