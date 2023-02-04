//
//  CustomToolbarView.swift
//  KeyboardToolbar
//
//  Created by Kamal Punia on 26/01/23.
//

import UIKit
import Photos
import KeyboardKit

protocol CustomToolbarViewDelegates: AnyObject {
    func toolbarView(_ view: CustomToolbarView, didSelectItemAt indexPath: IndexPath, image: UIImage?, imageName: String?, url: URL?)
    func toolbarView(_ view: CustomToolbarView, didSelectItemAt indexPath: IndexPath, videoUrl: URL?, videoName: String?, thumbnail: UIImage?)
    func toolbarView(_ view: CustomToolbarView, askFor permissions: Bool)
}

protocol CustomToolbarViewHeightDelegates: AnyObject {
    func toolbarView(_ view: CustomToolbarView, updateHeight: CGFloat)
}

class CustomToolbarView: UIView {

    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var allowAccessLabel: UILabel!
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Variables
    private var photoLibrary = PhotoService()
    private let cellId = "CustomToolbarViewCell"
//    weak var delegate: CustomToolbarViewDelegates?
    weak var heightDelegate: CustomToolbarViewHeightDelegates?
    private var latestPhotoAssetsFetched: PHFetchResult<PHAsset>? = nil
//    var textField: UITextField?
    private var enableCameraButton = false
    private let handler = ViewController()
    var textInputProxy: UITextDocumentProxy?
    private var isInitialized: Bool = false
    
    // MARK: - View life cycle
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.initialize()
    }
    
    override var intrinsicContentSize: CGSize {
        return self.bounds.size
    }
    
    // MARK: - IBAction
    @IBAction func cameraButtonAction(_ sender: UIButton) {
        if self.enableCameraButton {
            self.hideSelectedImageView()
            self.showImages()
        }else {
            self.handler.toolbarView(self, askFor: true)
        }
    }
    
    @IBAction func logoButtonAction(_ sender: UIButton) {
        self.openWebsite()
    }
    
    // MARK: - Internal function
    func showLoader(show: Bool) {
        self.loaderView.isHidden = !show
        if show {
            self.activityIndicator.startAnimating()
        }else {
            self.activityIndicator.stopAnimating()
        }
    }
    
    func showImages() {
        self.collectionView.isHidden = false
        self.collectionHeightConstraint.constant = AppConstants.imagesCollectionViewHeight
//        self.textField?.reloadInputViews()
        self.layoutIfNeeded()
        self.heightDelegate?.toolbarView(self, updateHeight: AppConstants.keyboardHeight + AppConstants.openToolbarHeight)
    }
    
    func enableCameraButton(enable: Bool) {
        self.enableCameraButton = enable
        self.allowAccessLabel.isHidden = enable
        if enable {
            self.getPhotos()
        }
    }
    
    func showSelectedImage(_ image: UIImage?) {
        self.selectedImageView.image = image
        self.selectedImageView.isHidden = false
    }
    
    func hideSelectedImageView() {
        self.selectedImageView.image = nil
        self.selectedImageView.isHidden = true
    }
    
    // MARK: - Private functions
    private func initialize() {
        if !self.isInitialized {
            self.showLoader(show: false)
            self.setupCollectionView()
            self.collectionView.isHidden = true
            self.collectionHeightConstraint.constant = 0
            self.layoutIfNeeded()
            self.handler.initialize(customToolbar: self, parentVC: self.parentViewController)
            self.isInitialized = true
        }
    }

    private func setupCollectionView() {
        let nib = UINib(nibName: self.cellId, bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: self.cellId)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    private func getPhotos() {
        DispatchQueue.global().async { [weak self] in
            self?.latestPhotoAssetsFetched = self?.photoLibrary.fetchLatestPhotos(forCount: AppConstants.totalImagesCount)
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }
    
    private func getAssetInfo(at index: Int) -> (String?, Bool) {
        
        guard let asset = self.latestPhotoAssetsFetched?[index] else {
            return (nil, false)
        }
        let isVideo = asset.mediaType == .video
        return (asset.localIdentifier, isVideo)
    }
    
    private func getThumbnail(at index: Int, for size: CGSize, completion: @escaping (UIImage?) -> ()) {

        guard let asset = self.latestPhotoAssetsFetched?[index] else {
                completion(nil)
                return
            }
        
            // Request the image.
            PHImageManager.default().requestImage(for: asset,
                                           targetSize: size,
                                          contentMode: .aspectFill,
                                              options: nil) { (image, _) in
                if let data = image?.jpegData(compressionQuality: 0.5),
                   let compressedImage = UIImage(data: data) {
                    completion(compressedImage)
                }else {
                    completion(image)
                }
            }
    }
    
    private func getOriginalImageURL(at index: Int, completion: @escaping (String?, URL?) -> ()) {
        
        guard let asset = self.latestPhotoAssetsFetched?[index] else {
            completion(nil, nil)
            return
        }
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        
        asset.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { input, info in
            
            let url = input?.fullSizeImageURL
            let fileName = url?.lastPathComponent
            completion(fileName, url)
        }
//        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, dataUti, orientation, info in
//            let assetResources = PHAssetResource.assetResources(for: asset)
//            let fileName = assetResources.first?.originalFilename
//            print(info)
//            let url = info?["PHImageFileURLKey"] as? URL
//            completion(fileName, url)
//        }
        
    }
    
    private func getVideo(at index: Int, completion: @escaping (URL?, String?) -> ()) {
        
        guard let asset = self.latestPhotoAssetsFetched?[index] else {
            completion(nil, nil)
            return
        }
        
        let options = PHVideoRequestOptions()
        options.deliveryMode = .highQualityFormat
        
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, avAudioMix, metaData in
            if let urlAsset = avAsset as? AVURLAsset {
                let videoUrl = urlAsset.url
                let assetResources = PHAssetResource.assetResources(for: asset)
                let fileName = assetResources.first?.originalFilename
                completion(videoUrl, fileName)
            }else {
                completion(nil, nil)
            }
        }
    }
    
    private func openWebsite() {
        guard let url = URL(string: AppConstants.websiteLink) else { return }
        let selectorOpenURL = NSSelectorFromString("openURL:")
        var responder: UIResponder? = self
        while let r = responder {
            if r.canPerformAction(selectorOpenURL, withSender: nil) {
                 r.perform(selectorOpenURL, with: url, afterDelay: 0.01)
                 break
            }
            responder = r.next
        }
    }
}

// MARK: - UICollectionViewDataSource
extension CustomToolbarView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ((self.latestPhotoAssetsFetched?.count ?? 0) + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellId, for: indexPath) as! CustomToolbarViewCell
        
        /*if indexPath.item == 0 {
            let image = UIImage(named: "cameraIcon")!
            cell.setupCellWith(image: image, border: true, isVideo: false)
            return cell
        }else */if indexPath.item == (self.latestPhotoAssetsFetched?.count ?? 0) {
            //last index
            let image = UIImage(named: "galleryIcon")!
            cell.setupCellWith(image: image, border: true, isVideo: false)
            return cell
        }
        let (identifier, isVideo) = self.getAssetInfo(at: indexPath.item)
        guard let identifier = identifier else {
            return cell
        }
        cell.representedAssetIdentifier = identifier
        
        self.getThumbnail(at: indexPath.item, for: cell.imageView.frame.size, completion: { image in
            if cell.representedAssetIdentifier == identifier,
               let thumbnail = image {
                cell.setupCellWith(image: thumbnail, isVideo: isVideo)
            }
        })
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension CustomToolbarView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let isLastIndex = indexPath.item == (self.latestPhotoAssetsFetched?.count ?? 0)
        if isLastIndex {
            self.handler.toolbarView(self, didSelectItemAt: indexPath, image: nil, imageName: nil, url: nil)
            return
        }
        
        if let cell = collectionView.cellForItem(at: indexPath) as? CustomToolbarViewCell {
            if cell.isVideo {
                self.getVideo(at: indexPath.item) { [weak self] videoURL, fileName in
                    guard let `self` = self else {return}
                    self.handler.toolbarView(self, didSelectItemAt: indexPath, videoUrl: videoURL, videoName: fileName, thumbnail: videoURL?.imageThumbnail())
                }
            }else {
                self.getOriginalImageURL(at: indexPath.item) { [weak self] fileName, url in
                    guard let `self` = self else {return}
                    self.handler.toolbarView(self, didSelectItemAt: indexPath, image: cell.imageView.image, imageName: fileName, url: url)
                }
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CustomToolbarView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        return CGSize(width: height, height: height)
    }
}
