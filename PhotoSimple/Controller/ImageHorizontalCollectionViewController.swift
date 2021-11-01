//
//  ImageHorizontalCollectionViewController.swift
//  PhotoSimple
//
//  Created by namgi on 2021/10/19.
//

import UIKit

class ImageHorizontalCollectionViewController: UIViewController {
    
    // MARK: - Properties
    private let imageCount: Int = 200
    private let imageNames: [String] = ["photo.on.rectangle.angled", "person.fill", "person.fill.turn.right", "person.fill.turn.down", "person.fill.turn.left"]
    private let emptyCellCount: Int = 7
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.showsHorizontalScrollIndicator = false
        
        self.imageView.image = .none
        
        self.setupFlowLayout()
    }
    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//
//        self.collectionView.selectItem(at: IndexPath(row: emptyCellCount, section: 0), animated: false, scrollPosition: .centeredHorizontally)
//    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.collectionView.selectItem(at: IndexPath(row: emptyCellCount, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }
    
    private func setupFlowLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.zero
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.minimumLineSpacing = 1
        
        let width: CGFloat = UIScreen.main.bounds.width / 15
        let heigth: CGFloat = 70
        
        flowLayout.itemSize = CGSize(width: width, height: heigth)
        flowLayout.scrollDirection = .horizontal
        
        self.collectionView.collectionViewLayout = flowLayout
    }
}

extension ImageHorizontalCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "horizontalImageCollectionCell", for: indexPath) as! ImageHorizontalCollectionViewCell
        
        if indexPath.row >= self.emptyCellCount && indexPath.row < self.imageCount - self.emptyCellCount {
            cell.isAvailable = true
            cell.imageView.image = UIImage(systemName: self.imageNames[indexPath.row % self.imageNames.count])
            
        } else {
            cell.isAvailable = false
            cell.imageView.image = .none
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 동작이 중복되어 주석처리 함.
//        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageHorizontalCollectionViewCell else { return }
//        self.imageView.image = cell.imageView.image
        
        // 셀 선택 시, 스크롤 중앙 이동 (selectItem 와의 차이 알아보기)
        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let cgPoint: CGPoint = self.centerPoint()
        
        // 수시로 메인 사진란에 보여주기
        if let indexPath = self.collectionView.indexPathForItem(at: cgPoint),
           let cell = self.collectionView.cellForItem(at: indexPath) as? ImageHorizontalCollectionViewCell {
            // print("row : \(indexPath.row)")
            self.imageView.image = cell.imageView.image
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let cgPoint: CGPoint = self.centerPoint()
        
        // 스크롤이 감속하여 멈췄을 때, 셀 중앙 이동 (scrollToItem 와의 차이 알아보기)
        if let indexPath = self.collectionView.indexPathForItem(at: cgPoint) {
            guard let cell = collectionView.cellForItem(at: indexPath) as? ImageHorizontalCollectionViewCell else { return }
            
            if cell.isAvailable == true {
                self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            } else {
                if indexPath.row < self.emptyCellCount {
                    self.collectionView.selectItem(at: IndexPath(row: self.emptyCellCount, section: 0), animated: true, scrollPosition: .centeredHorizontally)
                } else {
                    self.collectionView.selectItem(at: IndexPath(row: self.imageCount - self.emptyCellCount - 1, section: 0), animated: true, scrollPosition: .centeredHorizontally)
                }
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageHorizontalCollectionViewCell else { return false }
        if cell.isAvailable == false {
            return false
        }
        
        return true
    }
    
}

extension ImageHorizontalCollectionViewController {
    
    // MARK: - Methods
    
    /// CollectionView 가운데 아이템을 가져오기 위한 Point 값
    /// - Returns: 가운데 Point 값
    private func centerPoint() -> CGPoint {
        let x: CGFloat = self.collectionView.contentOffset.x + self.collectionView.center.x
        let y: CGFloat = 0
        
        return CGPoint(x: x, y: y)
    }
}
