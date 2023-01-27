//
//  CustomToolbarView.swift
//  KeyboardToolbar
//
//  Created by Kamal Punia on 26/01/23.
//

import UIKit
import Photos

protocol CustomToolbarViewDelegates: AnyObject {
    func toolbarView(_ view: CustomToolbarView, didSelectItemAt indexPath: IndexPath)
}

class CustomToolbarView: UIView {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var photoLibrary = PhotoService()
    private let cellId = "CustomToolbarViewCell"
    weak var delegate: CustomToolbarViewDelegates?
    private var latestPhotoAssetsFetched: PHFetchResult<PHAsset>? = nil
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.initialize()
    }
    
    @IBAction func camerButtonAction(_ sender: UIButton) {
        self.showImages()
    }
    
    func showImages() {
        self.collectionView.isHidden = false
    }
    
    private func initialize() {
        self.setupCollectionView()
        self.getPhotos()
        self.collectionView.isHidden = true
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
    
    func getIdentifier(at index: Int) -> String? {
        
        guard let asset = self.latestPhotoAssetsFetched?[index] else {
            return nil
        }
        return asset.localIdentifier
    }
    
    func getPhoto(at index: Int, for size: CGSize, completion: @escaping (UIImage?) -> ()) {

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

extension CustomToolbarView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ((self.latestPhotoAssetsFetched?.count ?? 0) + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellId, for: indexPath) as! CustomToolbarViewCell
        
        if indexPath.item == 0 {
            cell.imageView.image = UIImage(named: "cameraIcon")
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

extension CustomToolbarView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.toolbarView(self, didSelectItemAt: indexPath)
    }
}

extension CustomToolbarView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        return CGSize(width: height, height: height)
    }
}
