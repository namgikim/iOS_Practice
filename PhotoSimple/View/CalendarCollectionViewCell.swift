//
//  CalendarCollectionViewCell.swift
//  PhotoSimple
//
//  Created by namgi on 2021/10/28.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    var year: Int = 0
    var month: Int = 0
    var day: Int = 0
    
    // MARK: - IBOutlets
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.year = 0
        self.month = 0
        self.day = 0
        self.dayLabel.text = ""
        self.infoLabel.text = ""
    }
}
