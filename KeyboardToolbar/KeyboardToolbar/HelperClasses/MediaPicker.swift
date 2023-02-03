//
//  MediaPicker.swift
//

import UIKit
import Photos
import MobileCoreServices
import UniformTypeIdentifiers

fileprivate struct Constants {
    static var chooseOption = "Choose Option"
    static var openCamera = "Open Camera"
    static var chooseGallery = "Choose From Gallery"
    static var cancel = "Cancel"
    static var alert = "Alert"
    static var setting = "Setting"
    static var permissionMessage = "You have denied the permissions, you can allow permissions from setting."
}

@objc protocol MediaPickerDelegate {
    @objc optional func mediaPicker(_ mediaPicker: MediaPicker, didChooseImage image: UIImage?, url: URL?, imageName: String?)
    @objc optional func mediaPicker(_ mediaPicker: MediaPicker, didChooseVideo url: URL?, videoName: String?, thumbnail: UIImage?)
    @objc optional func mediaPickerDidCancel(_ mediaPicker: MediaPicker)
}

class MediaPicker: NSObject {
    
    private var picker: UIImagePickerController!
    static var shared = MediaPicker()
    private weak var delegate: MediaPickerDelegate?
    private var allowEditing = false
    private var allowVideoSelectionOnly = false
    
    func setupPicker(delegate: MediaPickerDelegate, allowEditing: Bool = false, allowVideoSelectionOnly: Bool) {
        self.delegate = delegate
        self.allowEditing = allowEditing
        self.allowVideoSelectionOnly = allowVideoSelectionOnly
    }
    
    /*func openActionSheetForImagePicker() {
        let optionMenu = UIAlertController(title: nil, message: Constants.chooseOption, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: Constants.openCamera, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.checkAuthorizationAndOpenPicker(with: .camera)
        })
        let libraryAction = UIAlertAction(title: Constants.chooseGallery, style: .default, handler:{
            (alert: UIAlertAction!) -> Void in
            self.checkAuthorizationAndOpenPicker(with: .photoLibrary)
        })
        let cancelAction = UIAlertAction(title: Constants.cancel, style: .cancel, handler:{
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(libraryAction)
        optionMenu.addAction(cancelAction)
        UIWindow.keyWindow?.rootViewController?.present(optionMenu, animated: true, completion: nil)
    }*/
    
    func checkAuthorizationAndOpenPicker(with type: UIImagePickerController.SourceType, on vc: UIViewController) {
        if type == .camera {
            self.checkAVPermission { [weak self] (finish) in
                DispatchQueue.main.async { [weak self] in
                    if finish {
                        self?.openPicker(with: type, on: vc)
                    }else {
                        //show open setting Alert
                        self?.showSettingAlertOn(vc: vc)
                    }
                }
            }
        }else if type == .photoLibrary {
            self.checkPhotoLibraryPermission { [weak self] (finish) in
                DispatchQueue.main.async { [weak self] in
                    if finish {
                        self?.openPicker(with: type, on: vc)
                    }else {
                        //show open setting Alert
                        self?.showSettingAlertOn(vc: vc)
                    }
                }
            }
        }
    }
    
    private func openPicker(with sourceType: UIImagePickerController.SourceType, on vc: UIViewController) {
        DispatchQueue.main.async {
            self.picker = UIImagePickerController()
            var sourceType = sourceType
            if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) && sourceType == .camera {
                sourceType = .photoLibrary
            }
            
            self.picker.delegate = self
            self.picker.sourceType = sourceType
            self.picker.allowsEditing = self.allowEditing
            if self.allowVideoSelectionOnly {
                self.picker.mediaTypes = [UTType.movie.identifier]
            }else {
                self.picker.mediaTypes = [UTType.image.identifier, UTType.movie.identifier]
            }
            vc.present(self.picker, animated: true, completion: nil)
        }
    }
    
    private func checkAVPermission(with type: AVMediaType = .video, completion: @escaping (Bool) -> ()) {
        if AVCaptureDevice.authorizationStatus(for: type) == .authorized {
            //already authorized
            completion(true)
        } else {
            AVCaptureDevice.requestAccess(for: type, completionHandler: { (granted: Bool) in
                if granted {
                    //access allowed
                    completion(true)
                } else {
                    //access denied
                    completion(false)
                }
            })
        }
    }
    
    func checkPhotoLibraryPermission(completion: @escaping (Bool) -> ()) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            //handle authorized status
            completion(true)
        case .denied, .restricted :
            //handle denied status
            completion(false)
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    // as above
                    completion(true)
                case .denied, .restricted:
                    // as above
                    completion(false)
                case .notDetermined:
                    // won't happen but still
                    completion(false)
                case .limited:
                    completion(true)
                @unknown default:
                    return
                }
            }
        case .limited:
            completion(true)
        @unknown default:
            return
        }
    }
}

// MARK: - IMAGE PICKER CONTROLLER DELEGATE
extension MediaPicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        var fileName: String?
        if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset {
            let assetResources = PHAssetResource.assetResources(for: asset)
            fileName = assetResources.first?.originalFilename
        }
        
        if let mediaType = info[.mediaType] as? String {

            if mediaType  == (UTType.image.identifier) {
                let key: UIImagePickerController.InfoKey = self.allowEditing ? .editedImage: .originalImage
                var image = info[key] as? UIImage
                if let data = image?.jpegData(compressionQuality: 0.3),
                   let thumbnail = UIImage(data: data) {
                    image = thumbnail
                }
                let imgUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL
                self.delegate?.mediaPicker?(self, didChooseImage: image, url: imgUrl, imageName: fileName)
            }

            if mediaType == (UTType.movie.identifier) {
                if let url = info[.mediaURL] as? URL {
                    self.delegate?.mediaPicker?(self, didChooseVideo: url, videoName: fileName, thumbnail: url.imageThumbnail())
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true, completion: nil)
        self.delegate?.mediaPickerDidCancel?(self)
    }
}

// MARK: - ALERT
extension MediaPicker {
    func showSettingAlertOn(vc: UIViewController) {
        let alert = UIAlertController(title: Constants.alert, message: Constants.permissionMessage, preferredStyle: .alert)
        let settingButton = UIAlertAction(title: Constants.setting, style: .default) { [weak self] (action) in
            //open setting
            self?.openSettings(vc: vc)
        }
        let cancelButton = UIAlertAction(title: Constants.cancel, style: .default, handler: nil)
        alert.addAction(settingButton)
        alert.addAction(cancelButton)
        vc.present(alert, animated: true, completion: nil)
    }
    
    private func openSettings(vc: UIViewController) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        let selectorOpenURL = NSSelectorFromString("openURL:")
        var responder: UIResponder? = vc
        while let r = responder {
            if r.canPerformAction(selectorOpenURL, withSender: nil) {
                 r.perform(selectorOpenURL, with: url, afterDelay: 0.01)
                 break
            }
            responder = r.next
        }
    }
}
