//
//  ListCollectionViewCell.swift
//  Reminders
//
//  Created by namgi on 2021/10/07.
//

import UIKit

class ListCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func prepareForReuse() {
        self.countLabel.text = "0"
    }
}
