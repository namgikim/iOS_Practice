//
//  ImageViewController.swift
//  PhotoSimple
//
//  Created by namgi on 2021/10/12.
//

import UIKit
import PhotosUI

class ImageViewController: UIViewController {
    
    // MARK: - Properties
    var picker = PHPickerViewController(configuration: {
        var config = PHPickerConfiguration()
        config.filter = .images // 사진만 선택할 수 있도록 함.
        return config
    }())
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var trashBarButtonItem: UIBarButtonItem!
    
    // MARK: - IBActions
    @IBAction func touchUpAddBarButtonItem(_ sender: UIBarButtonItem) {
        self.authorizationStatus { (result: Bool) in
            
            if result == true {
                self.present(self.picker, animated: true, completion: nil)
                
            } else {
                let alert = UIAlertController(title: "권한 설정",
                                              message: "[설정 - 사진 접근] 을 허용한 후 진행하세요.",
                                              preferredStyle: .alert)
                let confirm = UIAlertAction(title: "확인", style: .default, handler: nil)
                
                alert.addAction(confirm)
                
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func touchUpSaveBarButtonItem(_ sender: UIBarButtonItem) {
        guard let image: UIImage = self.imageView.image else { return }
        
        let name: String = String(Date().timeIntervalSince1970) + ".jpeg"
        
        ImageFileManager.shared.saveImage(image: image, name: name) { (result) in
            self.loadImage()
            
            print("File save result : \(result ? "Success" : "Fail")")
        }
    }
    
    @IBAction func touchUpTrashBarButtonItem(_ sender: UIBarButtonItem) {
        let alert: UIAlertController = UIAlertController(title: "사진 삭제",
                                                         message: "등록된 사진을 삭제하시겠습니까?",
                                                         preferredStyle: .alert)
        let delete: UIAlertAction = UIAlertAction(title: "삭제",
                                                  style: .destructive) { (UIAlertAction) in
            ImageFileManager.shared.removeImage { (result) in
                
                if result { self.loadImage() }
                
                print("File remove result : \(result ? "Success" : "Fail")")
            }
        }
        
        let cancel: UIAlertAction = UIAlertAction(title: "취소",
                                                  style: .cancel,
                                                  handler: nil)
        
        alert.addAction(delete)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.picker.delegate = self
        
        self.loadImage()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ImageViewController {
    
    // MARK: - Methods
    private func authorizationStatus(completion: @escaping ((Bool) -> Void)) {
        
        let handler: ((PHAuthorizationStatus) -> Void) = { (status) in
            switch status {
            case .authorized:
                print("authorized granted")
                completion(true)
            case .limited:
                print("limited granted")
                completion(true)
            default:
                print("Not granted")
                completion(false)
            }
        }
        
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized:
            print("status: authorized")
            completion(true)
        case .limited:
            print("status: limited")
            completion(true)
        case .denied:
            print("사용자가 사진 라이브러리에 접근을 거부했습니다.")
            completion(false)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: handler)
        case .restricted:
            print("앱이 사진 라이브러리에 접근할 수 있는 권한이 없습니다.")
            completion(false)
        @unknown default:
            fatalError()
        }
    }
    
    private func loadImage() {
        
        if let image: UIImage = ImageFileManager.shared.loadImage(),
           let imageData: ImageFileManager.ImageData = ImageFileManager.shared.loadImageData() {
            self.imageView.image = image
            
            var text: String = ""
            text.append("[Image path] \(ImageFileManager.shared.imageDirectoryURL?.path ?? "..")/\(imageData.name)")
            text.append("\n\n")
            text.append("[Image name] \(imageData.name)")
            self.textView.text = text
            self.trashBarButtonItem.isEnabled = true
            
        } else {
            self.imageView.image = UIImage(systemName: "photo")
            self.textView.text = "Image load status : Fail"
            self.trashBarButtonItem.isEnabled = false
        }
    }
}

extension ImageViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        self.picker.dismiss(animated: true, completion: nil)
        
        if let itemProvider: NSItemProvider = results.first?.itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) == true {
            itemProvider.loadObject(ofClass: UIImage.self) { (image, error: Error?) in
                DispatchQueue.main.async {
                    self.imageView.image = image as? UIImage
                }
            }
        }
    }
}
