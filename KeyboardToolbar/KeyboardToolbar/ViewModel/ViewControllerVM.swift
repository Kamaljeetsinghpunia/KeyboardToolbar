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
    
    // MARK: - Internal functions
    func uploadImage(completion: @escaping ApiResponseCompletion) {
        
        let multipartModel = self.requestModel.multipartModel
        
        ///Calling api service method
        self.apiServices.uploadImage([:], multipartModelArray: multipartModel, uploadType: .data) { [weak self] (result) in
            switch result {
            case .success(let response):
                guard let data = response.resultData as? Data else {
                    completion(.failure(ApiResponseErrorBlock(message: LocalizedStringEnum.somethingWentWrong.localized)))
                    return
                }
                /*///Converting api Data response to respective response model.
                self?.responseModel = JSONDecoder().convertDataToModel(data)
                ///Clear request model.
                self?.requestModel = CreatePostRequestModel()*/
                completion(.success(response))
            case .failure(let error):
                ///Handle failure response
                completion(.failure(error))
            }
        }
    }
}
