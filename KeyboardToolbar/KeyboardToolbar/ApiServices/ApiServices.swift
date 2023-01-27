//
//  ApiServices.swift
//

import Foundation


fileprivate enum ApiServicesEndPoints: APIService {
    //Define cases according to API's
    case uploadImage(_ parameters: [String: Any])
    
    //Return path according to api case
    var path: String {
        switch self {
        case .uploadImage:
            return "http://nostr.build/upload.php"
        }
    }
    
    //Return resource according to api case
    var resource: Resource {
        let headersWithToken: [String: Any] = [
            "Content-Type": "application/json"/*,
            "Authorization": "Bearer \("AppCache.shared.token")"*/
        ]
        
        switch self {
        case .uploadImage(let params):
            return Resource(method: .post, parameters: params, encoding: .QUERY, headers: headersWithToken, validator: APIDataResultValidator(), responseType: .data)
            
        }
    }
    
}

struct ApiServices {
    
    func uploadImage(_ parameters: [String: Any], multipartModelArray: [MultipartModel], uploadType: MultipartUploadType, completionBlock: @escaping ApiResponseCompletion) {
        ApiServicesEndPoints.uploadImage(parameters).requestMultipart(modelArray: multipartModelArray, uploadType: uploadType, completionBlock: completionBlock)
    }
    
}
