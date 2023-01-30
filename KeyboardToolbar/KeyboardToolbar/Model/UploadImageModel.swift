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
    var mimeType: MimeType = .image
    var videoUrl: URL?
    
    var multipartModel: [MultipartModel] {
        
        let name = self.fileName ?? "file_\(Date().getString(format: .dateTime))\(self.mimeType == .image ? ".png" : ".mp4")"
        let model = MultipartModel(key: "fileToUpload", data: self.selectedImage?.pngData(), url: videoUrl, mimeType: self.mimeType, fileName: name)
        return [model]
    }
    
}
