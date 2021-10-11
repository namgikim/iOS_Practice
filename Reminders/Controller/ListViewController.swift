//
//  ListViewController.swift
//  Reminders
//
//  Created by namgi on 2021/09/20.
//

import UIKit

class ListViewController: UIViewController {
    
    static let storyboardID: String = "ListViewController"
    
    // MARK: - Properties
    var list: List?
    var copiedList: List?
    var showTitle: String = "새로운 목록"
    let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    var selectedColorIndex: Int = 2 // 2:systemOrange
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var successButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var symbolImageView: UIImageView!
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isModalInPresentation = true
        self.presentationController?.delegate = self
        
        self.titleTextField.delegate = self
        self.titleTextField.becomeFirstResponder()
        
        self.copiedList = self.list // 변경사항 체크할 때 사용할 변수 copyList.
        
        // 색상 초기설정
        if let color: Int = self.list?.color { self.selectedColorIndex = color }
        self.titleTextField.textColor = colors[self.selectedColorIndex]
        self.symbolImageView.tintColor = colors[self.selectedColorIndex]
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.initializeView()
    }
}

extension ListViewController {
    
    // MARK: - IBActions
    @IBAction func touchUpCancelButton(_ sender: UIButton) {
        
        self.dismissAfterAlert()
    }
    
    @IBAction func touchUpSuccessButton(_ sender: UIButton) {
        
        guard let title: String = self.titleTextField.text,
              title.isEmpty == false else {
            return
        }
        
        // 값이 없다면 새로 생성 목록이기에 새로운 값을 할당한다.
        let id: String = self.list?.id ?? String(Date().timeIntervalSince1970)
        
        if self.list == nil {
            self.list = List(id: id, title: title)
        }
        
        // 선택한 색상 저장을 위한 셋팅
        self.list?.color = self.selectedColorIndex
        
        var isSuccess: Bool = false
        if let list: List = self.list {
            isSuccess = list.save {
                
                // ListViewController 가 무조건 Modal로 띄웠다는 전제하에 아래코드를 사용한다.
                self.dismiss(animated: true, completion: {
                    let userInfo: [String: Any] = [userInfoKeyDidEditDataNotification: "list",
                                                   userInfoKeyDidEditDataNotificationValue: list]
                    
                    NotificationCenter.default.post(name: userDidEditDataNotificationName,
                                                    object: nil,
                                                    userInfo: userInfo)
                })
            }
        }
        
        if isSuccess == false {
            print("Save Error...")
        }
    }
    
    @IBAction func tapBackground(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}

extension ListViewController: UITextFieldDelegate {
    
    private func initializeView() {
        
        self.titleLabel.text = self.showTitle
        
        if self.list != nil {
            self.titleTextField.text = self.list?.title
        }
    }
    
    // 목록 이름 입력란의 변화를 감지해서 완료버튼의 활성화 여부를 체크함.
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let title: String = self.titleTextField.text,
              title.isEmpty == false else {
            self.successButton.isEnabled = false
            return
        }
        self.list?.title = title
        self.successButton.isEnabled = true
    }
}

extension ListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCollectionCell", for: indexPath) as! ColorCollectionViewCell
        
        let colorIndex: Int = indexPath.row + 1
        cell.colorImageView.tintColor = colors[colorIndex]
        
        return cell
    }
}

extension ListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width
        let height = collectionView.frame.height
        
        let itemsPerRow: CGFloat = 6 // 한 줄에 표현할 개수
        let widthPadding = sectionInsets.left * (itemsPerRow + 1)
        let itemsPerColumn: CGFloat = 2 // 총 row수
        let heightPadding = sectionInsets.top * (itemsPerColumn + 1)
//        let heightPadding = sectionInsets.top * (itemsPerColumn)
        
        let cellWidth = (width - widthPadding) / itemsPerRow
        let cellHeight = (height - heightPadding) / itemsPerColumn
        
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let colorIndex: Int = indexPath.row + 1
        self.selectedColorIndex = colorIndex
        
        self.titleTextField.textColor = colors[self.selectedColorIndex]
        self.symbolImageView.tintColor = colors[self.selectedColorIndex]
    }
}

extension ListViewController {
    
    // MARK: - Methods
    private func dismissAfterAlert() {
        
        guard let title: String = self.titleTextField.text else {
            return
        }
        
        // 기존 목록을 수정하는 경우에서 변경사항이 없을 때는 Action Sheet 를 띄우지 않는다
        if let copiedList: List = self.copiedList,
           title == copiedList.title {
            
            self.dismiss(animated: true, completion: nil)
            
        // 새로운 목록의 경우에서 입력값이 없을 때는 Action Sheet 을 띄우지 않는다.
        } else if self.copiedList == nil,
                  title.isEmpty {
            self.dismiss(animated: true, completion: nil)
            
        // 그 외에는 Action Sheet 을 띄운다.
        } else {
            
            popDiscardChangesAlert(discard: {
                self.dismiss(animated: true, completion: nil)
            }) { (alert: UIAlertController) in
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension ListViewController: UIAdaptivePresentationControllerDelegate {
    
    // 현재 컨트롤러를 delegate로 설정한 후 사용해야한다.
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        self.dismissAfterAlert()
    }
}
