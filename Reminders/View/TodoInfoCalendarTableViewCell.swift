//
//  TodoInfoCalencalTableViewCell.swift
//  Reminders
//
//  Created by namgi on 2021/09/30.
//

import UIKit

protocol TodoInfoCalendarTableViewCellDelegate {
    func valueChangedDatePicker(_ sender: TodoInfoCalendarTableViewCell)
}

class TodoInfoCalendarTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    var delegate: TodoInfoCalendarTableViewCellDelegate?
    
    // MARK: - IBOutlets
    @IBOutlet weak var datePicker: UIDatePicker!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.datePicker.preferredDatePickerStyle = .inline
        self.datePicker.locale = Locale(identifier: "ko")
        self.datePicker.addTarget(self, action: #selector(valueChangedDatePicker(_:)), for: .valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension TodoInfoCalendarTableViewCell {
    
    // MARK: - Methods
    @objc private func valueChangedDatePicker(_ sender: UIDatePicker) {
        delegate?.valueChangedDatePicker(self)
    }
}
