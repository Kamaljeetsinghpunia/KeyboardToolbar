//
//  ViewController.swift
//  KeyboardToolbar
//
//  Created by Kamal Punia on 26/01/23.
//

import UIKit
import Photos

struct PhotoModel {
    var image: UIImage?
    var identifier: String
}

class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var toolbar: UIToolbar!
    
    // MARK: - Variables
    var photosArray = AtomicArray<Int>()
    private lazy var photoLibrary = PhotoService()
    private var albums = [PhotoAlbumViewModel]()
    
    var latestPhotoAssetsFetched: PHFetchResult<PHAsset>? = nil
    var customToolbar: CustomToolbarView?
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupToolbar()
        
    }

    // MARK: - IBActions
    @IBAction func chooseImageButtonAction(_ sender: UIBarButtonItem) {
        
    }
    
    // MARK: - Private functions
    private func setupToolbar() {
        let toolbar: CustomToolbarView = .loadFromNib()
        let toolbarHeight = UIScreen.main.bounds.size
        toolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 140)
        self.textField.inputAccessoryView = toolbar
    }
    
    
}

