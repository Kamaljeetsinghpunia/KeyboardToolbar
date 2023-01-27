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
    
    // MARK: - View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupUI()
    }

    // MARK: - Internal function
    func setupCellWith(image: UIImage, border: Bool = false) {
        self.imageView.image = image
        if border {
            self.imageView.addBorder(color: .white, width: 2)
        }else {
            self.imageView.addBorder(color: .clear, width: 2)
        }
    }
    
    // MARK: - Private functions
    private func setupUI() {
        self.imageView.roundCornerWithRadius(10)
    }
}
