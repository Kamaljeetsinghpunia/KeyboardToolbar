//
//  ViewController.swift
//  KeyboardToolbar
//
//  Created by Kamal Punia on 26/01/23.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var textField: UITextField!
    
    // MARK: - Variables
    private lazy var photoLibrary = PhotoService()
    private let viewModel = ViewControllerVM()
    private var customToolbar: CustomToolbarView?
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupToolbar()
        self.checkGalleryPermissions()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.textField.resignFirstResponder()
    }

    // MARK: - Private functions
    private func checkGalleryPermissions() {
        MediaPicker.shared.setupPicker(delegate: self, allowVideoSelectionOnly: false)
        MediaPicker.shared.checkPhotoLibraryPermission { [weak self] (finish) in
            DispatchQueue.main.async { [weak self] in
                if finish {
                    self?.customToolbar?.enableCameraButton(enable: true)
                }else {
                    //show open setting Alert
                    MediaPicker.shared.showSettingAlert()
                }
            }
        }
    }
    
    private func setupToolbar() {
        self.customToolbar = .loadFromNib()
        self.customToolbar?.delegate = self
        self.customToolbar?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40)
        self.customToolbar?.backgroundColor = .systemBackground
        self.customToolbar?.textField = self.textField
        self.textField.inputAccessoryView?.autoresizingMask = .flexibleHeight
        self.textField.inputAccessoryView = self.customToolbar
    }
    
    private func showImagePicker() {
        MediaPicker.shared.setupPicker(delegate: self, allowVideoSelectionOnly: false)
        MediaPicker.shared.openActionSheetForImagePicker()
    }
}

// MARK: - CustomToolbarViewDelegates
extension ViewController: CustomToolbarViewDelegates {
    
    func toolbarView(_ view: CustomToolbarView, didSelectItemAt indexPath: IndexPath, image: UIImage?, imageName: String?) {
        if indexPath.item == 0 {
            //First index for open the camera
            MediaPicker.shared.checkAuthorizationAndOpenPicker(with: .camera)
        }else if indexPath.item == (AppConstants.totalImagesCount + 1) {
            //Last index for open the gallery
            MediaPicker.shared.checkAuthorizationAndOpenPicker(with: .photoLibrary)
        }else {
            self.viewModel.requestModel.selectedImage = image
            self.viewModel.requestModel.fileName = imageName
            self.viewModel.requestModel.mimeType = .image
            self.uploadFile()
        }
    }
    
    func toolbarView(_ view: CustomToolbarView, didSelectItemAt indexPath: IndexPath, videoUrl: URL?, videoName: String?, thumbnail: UIImage?) {
        self.viewModel.requestModel.videoUrl = videoUrl
        self.viewModel.requestModel.selectedImage = thumbnail
        self.viewModel.requestModel.fileName = videoName
        self.viewModel.requestModel.mimeType = .video
        self.uploadFile()
    }
    
    func toolbarView(_ view: CustomToolbarView, askFor permissions: Bool) {
        if permissions {
            self.checkGalleryPermissions()
        }
    }
    
}

// MARK: - MediaPickerDelegate
extension ViewController: MediaPickerDelegate {
    func mediaPicker(_ mediaPicker: MediaPicker, didChooseImage image: UIImage?, imageName: String?) {
        self.viewModel.requestModel.selectedImage = image
        self.viewModel.requestModel.fileName = imageName
        self.viewModel.requestModel.mimeType = .image
        self.uploadFile()
    }
    
    func mediaPicker(_ mediaPicker: MediaPicker, didChooseVideo url: URL?, videoName: String?, thumbnail: UIImage?) {
        self.viewModel.requestModel.selectedImage = thumbnail
        self.viewModel.requestModel.videoUrl = url
        self.viewModel.requestModel.fileName = videoName
        self.viewModel.requestModel.mimeType = .video
        self.uploadFile()
    }
}

// MARK: - Api functions
extension ViewController {
    func uploadFile() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else {
                return
            }
            CustomLoader.shared.show()
            self.textField.resignFirstResponder()
            self.viewModel.uploadFile { [weak self] result in
                CustomLoader.shared.hide()
                guard let `self` = self else {
                    return
                }
                self.textField.becomeFirstResponder()
                self.textField.text = self.viewModel.imageUrl
                self.customToolbar?.showSelectedImage(self.viewModel.requestModel.selectedImage)
            }
        }
    }
}
