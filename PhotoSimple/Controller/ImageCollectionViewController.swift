//
//  ImageCollectionViewController.swift
//  PhotoSimple
//
//  Created by namgi on 2021/10/16.
//

import UIKit

class ImageCollectionViewController: UIViewController {
    
    // MARK: - Properties
    private var numberOfItems: CGFloat = 3
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    // MARK: - IBActions
    @IBAction func touchUpRefreshBarButton(_ sender: UIBarButtonItem) {
        if self.numberOfItems == 3 {
            self.numberOfItems = 5
        } else if self.numberOfItems == 5 {
            self.numberOfItems = 11
        } else {
            self.numberOfItems = 3
        }
        
        self.setupFlowLayout()
        
        imageCollectionView.performBatchUpdates({
            self.imageCollectionView.reloadSections(IndexSet(integer: 0))
        }, completion: nil)
    }
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        
        setupFlowLayout()
    }
}

extension ImageCollectionViewController {
    
    // Methods
    private func setupFlowLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.zero
        flowLayout.minimumInteritemSpacing = 3 // 아이템 간 최소거리
        flowLayout.minimumLineSpacing = 3 // 행 간 최소거리
        
        let halfWidth: CGFloat = (UIScreen.main.bounds.width / self.numberOfItems) - ((flowLayout.minimumInteritemSpacing * (self.numberOfItems - 1)) / self.numberOfItems)
        
        flowLayout.itemSize = CGSize(width: halfWidth, height: halfWidth)
//        flowLayout.footerReferenceSize = CGSize(width: halfWidth * 3, height: 70)
//        flowLayout.sectionFootersPinToVisibleBounds = true
        self.imageCollectionView.collectionViewLayout = flowLayout
    }
}

extension ImageCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCollectionCell", for: indexPath) as! ImageCollectionViewCell
        
        cell.backgroundColor = .systemGray6
        
        return cell
    }
}
