//
//  ImageHorizontalCollectionViewCell.swift
//  PhotoSimple
//
//  Created by namgi on 2021/10/19.
//

import UIKit

class ImageHorizontalCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageView.image = UIImage(systemName: "photo.on.rectangle.angled")
    }
}
