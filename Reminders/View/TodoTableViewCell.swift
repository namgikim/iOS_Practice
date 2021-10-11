//
//  TodoTableViewCell.swift
//  Reminders
//
//  Created by namgi on 2021/09/25.
//

import UIKit

protocol TodoTableViewCellDelegate {
    func todoCellEndEditing(_ sender: TodoTableViewCell)
    func todoCellBeginEditing(_ sender: TodoTableViewCell)
    func todoCellTouchUpSuccessButton(_ sender: TodoTableViewCell)
    func todoCellDidChange(_ sender: TodoTableViewCell)
}

class TodoTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    var delegate: TodoTableViewCellDelegate?
    
    // MARK: - IBOutlets
    @IBOutlet weak var successButton: UIButton!
    @IBOutlet weak var titleTextView: UITextView!
    
    // MARK: - IBActions
    @IBAction func touchUpSuccessButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        delegate?.todoCellTouchUpSuccessButton(self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.titleTextView.delegate = self
        
        // TableViewCell 안에 있는 TextView의 row 에 따른 높이 변화를 위한 설정
        self.titleTextView.isScrollEnabled = false
        self.titleTextView.sizeToFit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        // row 선택에 대한 동작은 처리하지 않는다.
    }
}

extension TodoTableViewCell: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.todoCellEndEditing(self)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.todoCellBeginEditing(self)
    }
    
    // TableViewCell 안에 있는 TextView의 row 에 따른 높이 변화를 위한 이벤트 감지
    func textViewDidChange(_ textView: UITextView) {
        delegate?.todoCellDidChange(self)
    }
}
