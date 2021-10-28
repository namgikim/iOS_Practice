//
//  ColorCollectionViewCell.swift
//  Reminders
//
//  Created by namgi on 2021/10/07.
//

import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            print("Test \(isSelected)")
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var colorImageView: UIImageView!
    

}
