//
//  ViewControllerVM.swift
//  KeyboardToolbar
//
//  Created by Kamal Punia on 27/01/23.
//

import Foundation

class ViewControllerVM: NSObject {
    // MARK: - Variables
    private let apiServices = ApiServices()
    var requestModel = UploadImageRequestModel()
    var imageUrl: String?
    
    // MARK: - Internal functions
    func uploadFile(completion: @escaping ApiResponseCompletion) {
        
        let multipartModel = self.requestModel.multipartModel
        
        ///Calling api service method
        self.apiServices.uploadFile([:], multipartModelArray: multipartModel, uploadType: .url) { [weak self] (result) in
            switch result {
            case .success(let response):
                guard let url = response.resultData as? String else {
                    completion(.failure(ApiResponseErrorBlock(message: LocalizedStringEnum.somethingWentWrong.localized)))
                    return
                }
                self?.imageUrl = url
                completion(.success(response))
            case .failure(let error):
                ///Handle failure response
                completion(.failure(error))
            }
            self?.requestModel = UploadImageRequestModel()
        }
    }
}
