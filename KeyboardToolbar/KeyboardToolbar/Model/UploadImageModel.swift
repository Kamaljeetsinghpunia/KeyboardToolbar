//
//  UploadImageModel.swift
//  KeyboardToolbar
//
//  Created by Kamal Punia on 27/01/23.
//

import UIKit

// MARK: - UploadImageRequestModel
struct UploadImageRequestModel {
    var selectedImage: UIImage?
    var fileName: String?
    
    var multipartModel: [MultipartModel] {

        let id = MultipartModel(key: "fileToUpload", data: self.selectedImage?.jpegData(compressionQuality: 1), url: nil, mimeType: .image, fileName: self.fileName ?? "file_\(Date().getString(format: .dateTime))")
        return [id]
    }
    
}
