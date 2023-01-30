//
//  CustomToolbarView.swift
//  KeyboardToolbar
//
//  Created by Kamal Punia on 26/01/23.
//

import UIKit
import Photos

protocol CustomToolbarViewDelegates: AnyObject {
    func toolbarView(_ view: CustomToolbarView, didSelectItemAt indexPath: IndexPath, image: UIImage?, imageName: String?)
    func toolbarView(_ view: CustomToolbarView, didSelectItemAt indexPath: IndexPath, videoUrl: URL?, videoName: String?, thumbnail: UIImage?)
    func toolbarView(_ view: CustomToolbarView, askFor permissions: Bool)
}

class CustomToolbarView: UIView {

    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedImageView: UIImageView!
    
    // MARK: - Variables
    private var photoLibrary = PhotoService()
    private let cellId = "CustomToolbarViewCell"
    weak var delegate: CustomToolbarViewDelegates?
    private var latestPhotoAssetsFetched: PHFetchResult<PHAsset>? = nil
    var textField: UITextField?
    private var enableCameraButton = false
    
    // MARK: - View life cycle
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.initialize()
    }
    
    @IBAction func cameraButtonAction(_ sender: UIButton) {
        if self.enableCameraButton {
            self.hideSelectedImageView()
            self.showImages()
        }else {
            self.delegate?.toolbarView(self, askFor: true)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return self.bounds.size
    }
    
    // MARK: - Internal function
    func showImages() {
        self.collectionView.isHidden = false
        self.collectionHeightConstraint.constant = 80
        self.textField?.reloadInputViews()
        self.layoutIfNeeded()
    }
    
    func enableCameraButton(enable: Bool) {
        self.enableCameraButton = enable
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
        self.setupCollectionView()
        self.collectionView.isHidden = true
        self.collectionHeightConstraint.constant = 0
        self.layoutIfNeeded()
    }

    private func setupCollectionView() {
        let nib = UINib(nibName: self.cellId, bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: self.cellId)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    private func getPhotos() {
        self.latestPhotoAssetsFetched = self.photoLibrary.fetchLatestPhotos(forCount: AppConstants.totalImagesCount)
        self.collectionView.reloadData()
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
                completion(image)
            }
    }
    
    private func getOriginalImage(at index: Int, completion: @escaping (UIImage?, String?) -> ()) {
        
        guard let asset = self.latestPhotoAssetsFetched?[index] else {
            completion(nil, nil)
            return
        }
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        
        PHImageManager.default().requestImage(for: asset,
                                              targetSize: PHImageManagerMaximumSize,
                                              contentMode: .default,
                                              options: options) { (image, metaData) in
            
            let assetResources = PHAssetResource.assetResources(for: asset)
            let fileName = assetResources.first?.originalFilename
            
            completion(image, fileName)
        }
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
}

// MARK: - UICollectionViewDataSource
extension CustomToolbarView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ((self.latestPhotoAssetsFetched?.count ?? 0) + 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellId, for: indexPath) as! CustomToolbarViewCell
        
        if indexPath.item == 0 {
            let image = UIImage(named: "cameraIcon")!
            cell.setupCellWith(image: image, border: true, isVideo: false)
            return cell
        }else if indexPath.item == (self.latestPhotoAssetsFetched?.count ?? 0) + 1 {
            //last index
            let image = UIImage(named: "galleryIcon")!
            cell.setupCellWith(image: image, border: true, isVideo: false)
            return cell
        }
        let (identifier, isVideo) = self.getAssetInfo(at: indexPath.item - 1)
        guard let identifier = identifier else {
            return cell
        }
        cell.representedAssetIdentifier = identifier
        
        self.getThumbnail(at: indexPath.item - 1, for: cell.imageView.frame.size, completion: { image in
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
        
        let isLastIndex = indexPath.item == (self.latestPhotoAssetsFetched?.count ?? 0) + 1
        if indexPath.item == 0 || isLastIndex {
            self.delegate?.toolbarView(self, didSelectItemAt: indexPath, image: nil, imageName: nil)
            return
        }
        
        if let cell = collectionView.cellForItem(at: indexPath) as? CustomToolbarViewCell {
            if cell.isVideo {
                self.getVideo(at: indexPath.item - 1) { videoURL, fileName in
                    self.delegate?.toolbarView(self, didSelectItemAt: indexPath, videoUrl: videoURL, videoName: fileName, thumbnail: videoURL?.imageThumbnail())
                }
            }else {
                self.getOriginalImage(at: indexPath.item - 1) { image, fileName in
                    self.delegate?.toolbarView(self, didSelectItemAt: indexPath, image: image, imageName: fileName)
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
