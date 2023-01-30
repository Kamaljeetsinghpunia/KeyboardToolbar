//
//  CustomToolbarViewCell.swift
//  KeyboardToolbar
//
//  Created by Kamal Punia on 26/01/23.
//

import UIKit

class CustomToolbarViewCell: UICollectionViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Variables
    var representedAssetIdentifier: String = ""
    var isVideo: Bool = false
    
    // MARK: - View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupUI()
    }

    // MARK: - Internal function
    func setupCellWith(image: UIImage, border: Bool = false, isVideo: Bool) {
        self.imageView.image = image
        self.isVideo = isVideo
        if border {
            self.imageView.addBorder(color: UIColor(named: "appPurple")!, width: 4)
        }else {
            self.imageView.addBorder(color: .clear, width: 4)
        }
    }
    
    // MARK: - Private functions
    private func setupUI() {
        self.imageView.roundCornerWithRadius(10)
    }
}
