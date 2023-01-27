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
    func toolbarView(_ view: CustomToolbarView, askFor permissions: Bool)
}

class CustomToolbarView: UIView {

    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionHeightConstraint: NSLayoutConstraint!
    
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
        self.latestPhotoAssetsFetched = self.photoLibrary.fetchLatestPhotos(forCount: 5)
        self.collectionView.reloadData()
    }
    
    private func getIdentifier(at index: Int) -> String? {
        
        guard let asset = self.latestPhotoAssetsFetched?[index] else {
            return nil
        }
        return asset.localIdentifier
    }
    
    private func getPhoto(at index: Int, for size: CGSize, completion: @escaping (UIImage?) -> ()) {

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
}

// MARK: - UICollectionViewDataSource
extension CustomToolbarView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ((self.latestPhotoAssetsFetched?.count ?? 0) + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellId, for: indexPath) as! CustomToolbarViewCell
        
        if indexPath.item == 0 {
            let image = UIImage(named: "cameraIcon")!
            cell.setupCellWith(image: image, border: true)
            return cell
        }
        
        guard let identifier = self.getIdentifier(at: indexPath.item - 1) else {
            return cell
        }
        cell.representedAssetIdentifier = identifier
        
        self.getPhoto(at: indexPath.item - 1, for: cell.imageView.frame.size, completion: { image in
            if cell.representedAssetIdentifier == identifier {
                cell.imageView.image = image
            }
        })
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension CustomToolbarView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CustomToolbarViewCell {
            self.delegate?.toolbarView(self, didSelectItemAt: indexPath, image: cell.imageView.image, imageName: nil)
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
