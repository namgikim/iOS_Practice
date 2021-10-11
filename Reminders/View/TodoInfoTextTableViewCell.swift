//
//  TodoInfoTextTableViewCell.swift
//  Reminders
//
//  Created by namgi on 2021/09/29.
//

import UIKit

protocol TodoInfoTextTableViewCellDelegate {
    func todoTextViewDidChange(_ sender: TodoInfoTextTableViewCell)
}

class TodoInfoTextTableViewCell: UITableViewCell {
    
    var delegate: TodoInfoTextTableViewCellDelegate?
    
    // MARK: - IBOutlets
    @IBOutlet weak var textView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.textView.delegate = self
        
        self.textView.isScrollEnabled = false
        self.textView.sizeToFit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension TodoInfoTextTableViewCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        delegate?.todoTextViewDidChange(self)
    }
}
