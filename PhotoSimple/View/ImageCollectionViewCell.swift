//
//  ImageCollectionViewCell.swift
//  PhotoSimple
//
//  Created by namgi on 2021/10/16.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageView.image = UIImage(systemName: "photo.on.rectangle.angled")
    }
    

}
