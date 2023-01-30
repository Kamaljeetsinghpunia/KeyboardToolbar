//
//  ApiServices.swift
//

import Foundation


fileprivate enum ApiServicesEndPoints: APIService {
    //Define cases according to API's
    case uploadFile(_ parameters: [String: Any])
    
    //Return path according to api case
    var path: String {
        switch self {
        case .uploadFile:
            return "\(AppConstants.baseUrl)/api/upload/nostrboard.php"
        }
    }
    
    //Return resource according to api case
    var resource: Resource {
        let headers: [String: Any] = [
            "Content-Type": "application/json"
        ]
        
        switch self {
        case .uploadFile(let params):
            return Resource(method: .post, parameters: params, encoding: .QUERY, headers: headers, validator: APIStringResultValidator(), responseType: .json)
            
        }
    }
    
}

struct ApiServices {
    
    func uploadFile(_ parameters: [String: Any], multipartModelArray: [MultipartModel], uploadType: MultipartUploadType, completionBlock: @escaping ApiResponseCompletion) {
        ApiServicesEndPoints.uploadFile(parameters).requestMultipart(modelArray: multipartModelArray, uploadType: uploadType, completionBlock: completionBlock)
    }
    
}
