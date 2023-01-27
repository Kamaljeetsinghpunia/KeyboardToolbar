//
//  AlamofireNetworkManager.swift
//

import Foundation
import Alamofire
import SwifterSwift

fileprivate enum AlertMessages: String {
    case somethingWentWrong
    
    var localized: String {
        return NSLocalizedString(self.rawValue, comment: self.rawValue)
    }
}

struct MultipartModel {
    var key: String
    var data: Data?
    var url: URL?
    var mimeType: MimeType
    var fileName: String
}

class AlamofireNetworkManager {
    
    func urlRequest(path: String, resource: Resource, completionBlock: @escaping ApiResponseCompletion) {
        if resource.responseType == .json {
            self.urlRequestForJsonResponse(path: path, resource: resource, completionBlock: completionBlock)
        }else if resource.responseType == .data {
            self.urlRequestForDataResponse(path: path, resource: resource, completionBlock: completionBlock)
        }
    }
    
    private func urlRequestForJsonResponse(path: String, resource: Resource, completionBlock: @escaping ApiResponseCompletion) {
        
        if !Network.reachability.isReachable {
            completionBlock(.failure(ApiResponseErrorBlock(message: LocalizedStringEnum.networkNotReachable.localized)))
            return
        }
        
        debugPrint("API path is: ", path)
        do {
            let request = self.createUrlRequest(path: path, resource: resource)
            AF.request(request).responseJSON { response in
                let statusCode = response.response?.statusCode ?? -1
                switch response.result {
                    
                case .success(let json):
                    debugPrint("API success code is: \(statusCode) and response is: ", json)
                    if resource.validator != nil {
                        resource.validator?.validateResponse(statusCode: statusCode, response: json, completionBlock: { (result) in
                            switch result {
                            case .success(let response):
                                completionBlock(.success(response))
                            case .failure(let error):
                                completionBlock(.failure(error))
                            }
                        })
                    }else {
                        let result = ApiResponseSuccessBlock(message: "", statusCode: response.response?.statusCode ?? -1, resultData: json)
                        completionBlock(.success(result))
                    }
                case .failure(let error):
                    debugPrint("API failure response is: ", error.localizedDescription)
                    let apiError = ApiResponseErrorBlock(message: error.localizedDescription)
                    completionBlock(.failure(apiError))
                }
            }
        }
    }
    
    private func urlRequestForDataResponse(path: String, resource: Resource, completionBlock: @escaping ApiResponseCompletion) {
        debugPrint("API path is: ", path)
        do {
            let request = self.createUrlRequest(path: path, resource: resource)
            AF.request(request).responseData { response in
                switch response.result {
                    
                case .success(let jsonData):
                   
                    if resource.validator != nil{
                        resource.validator?.validateResponse(statusCode: response.response?.statusCode ?? -1, response: jsonData, completionBlock: { (result) in
                            switch result {
                            case .success(let response):
                                completionBlock(.success(response))
                            case .failure(let error):
                                completionBlock(.failure(error))
                            }
                        })
                    }else {
                        let result = ApiResponseSuccessBlock(message: "", statusCode: response.response?.statusCode ?? -1, resultData: jsonData)
                        completionBlock(.success(result))
                    }
                case .failure(let error):
                    debugPrint("API response error: ", error.localizedDescription)
                    let apiError = ApiResponseErrorBlock(message: error.localizedDescription)
                    completionBlock(.failure(apiError))
                }
            }
        }
    }
    
    func request(path: String, resource: Resource, completionBlock: @escaping ApiResponseCompletion) {
        if resource.responseType == .json {
            self.requestForJsonResponse(path: path, resource: resource, completionBlock: completionBlock)
        }else if resource.responseType == .data {
            self.requestForDataResponse(path: path, resource: resource, completionBlock: completionBlock)
        }
    }
    
    private func requestForJsonResponse(path: String, resource: Resource, completionBlock: @escaping ApiResponseCompletion) {
        debugPrint("API path is: ", path)
        debugPrint("Request parameters: ", resource.parameters ?? [:])
        do {
            AF.request(path, method: self.getHTTPMethodType(type: resource.method), parameters: resource.parameters, encoding: self.getURLEncodingType(type: resource.encoding), headers: self.getHttpHeader(headers: resource.headers)).responseJSON { response in
                switch response.result {
                    
                case .success(let json):
                    debugPrint("API response is: ", json)
                    if resource.validator != nil{
                        resource.validator?.validateResponse(statusCode: response.response?.statusCode ?? -1, response: json, completionBlock: { (result) in
                            switch result {
                            case .success(let response):
                                completionBlock(.success(response))
                            case .failure(let error):
                                completionBlock(.failure(error))
                            }
                        })
                    }
                    else {
                        let result = ApiResponseSuccessBlock(message: "", statusCode: response.response?.statusCode ?? -1, resultData: json)
                        completionBlock(.success(result))
                    }
                case .failure(let error):
                    debugPrint("API response error: ", error.localizedDescription)
                    let apiError = ApiResponseErrorBlock(message: error.localizedDescription)
                    completionBlock(.failure(apiError))
                }
            }
        }
    }
    
    private func requestForDataResponse(path: String, resource: Resource, completionBlock: @escaping ApiResponseCompletion) {
        debugPrint("API path is: ", path)
        debugPrint("Request parameters: ", resource.parameters ?? [:])
        do {
            AF.request(path, method: self.getHTTPMethodType(type: resource.method), parameters: resource.parameters, encoding: self.getURLEncodingType(type: resource.encoding), headers: self.getHttpHeader(headers: resource.headers)).responseData { response in
                switch response.result {
                    
                case .success(let json):
                    debugPrint("API response is: ", json)
                    if resource.validator != nil{
                        resource.validator?.validateResponse(statusCode: response.response?.statusCode ?? -1, response: json, completionBlock: { (result) in
                            switch result {
                            case .success(let response):
                                completionBlock(.success(response))
                            case .failure(let error):
                                completionBlock(.failure(error))
                            }
                        })
                    }else {
                        let result = ApiResponseSuccessBlock(message: "", statusCode: response.response?.statusCode ?? -1, resultData: json)
                        completionBlock(.success(result))
                    }
                case .failure(let error):
                    debugPrint("API response error: ", error.localizedDescription)
                    let apiError = ApiResponseErrorBlock(message: error.localizedDescription)
                    completionBlock(.failure(apiError))
                }
            }
        }
    }
    
    func multipartRequest(path: String, resource: Resource, modelArray: [MultipartModel], uploadType: MultipartUploadType, completionBlock: @escaping ApiResponseCompletion) {
        if resource.responseType == .json {
            self.multipartRequestForJsonResponse(path: path, resource: resource, modelArray: modelArray, uploadType: uploadType, completionBlock: completionBlock)
        }else if resource.responseType == .data {
            self.multipartRequestForDataResponse(path: path, resource: resource, modelArray: modelArray, uploadType: uploadType, completionBlock: completionBlock)
        }
    }
    
    private func multipartRequestForDataResponse(path: String, resource: Resource, modelArray: [MultipartModel], uploadType: MultipartUploadType, completionBlock: @escaping ApiResponseCompletion) {
        
        debugPrint("path: ", path)
        debugPrint("params: ", resource.parameters)
        debugPrint("headers: ", resource.headers)
        debugPrint("keys: ", modelArray.map({$0.key}))
        debugPrint("fileData: ", modelArray.map({$0.data}))
        debugPrint("fileURL: ", modelArray.map({$0.url}))
        debugPrint("mimeType: ", modelArray.map({$0.mimeType}))
        debugPrint("fileName: ", modelArray.map({$0.fileName}))
        debugPrint("uploadType: ", uploadType)
        
        AF.upload(multipartFormData: { multipartFormData in
            
            if uploadType == .data {
                for model in modelArray {
                    multipartFormData.append(model.data!, withName: model.key, fileName: model.fileName, mimeType: model.mimeType.rawValue)
                }
            }else {//url
                for model in modelArray {
                    multipartFormData.append(model.url!, withName: model.key, fileName: model.fileName, mimeType: model.mimeType.rawValue)
                }
            }
            
            for (key, value) in resource.parameters ?? [:] {
                    multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
            }
        }, to: path, method: self.getHTTPMethodType(type: resource.method), headers: self.getHttpHeader(headers: resource.headers))
            .responseData { response in
                switch response.result {
                    
                case .success(let jsonData):
                   
                    if resource.validator != nil{
                        resource.validator?.validateResponse(statusCode: response.response?.statusCode ?? -1, response: jsonData, completionBlock: { (result) in
                            switch result {
                            case .success(let response):
                                completionBlock(.success(response))
                            case .failure(let error):
                                completionBlock(.failure(error))
                            }
                        })
                    }else {
                        let result = ApiResponseSuccessBlock(message: "", statusCode: response.response?.statusCode ?? -1, resultData: jsonData)
                        completionBlock(.success(result))
                    }
                case .failure(let error):
                    debugPrint("API response error: ", error.localizedDescription)
                    let apiError = ApiResponseErrorBlock(message: error.localizedDescription)
                    completionBlock(.failure(apiError))
                }
            }
    }
    
    private func multipartRequestForJsonResponse(path: String, resource: Resource, modelArray: [MultipartModel], uploadType: MultipartUploadType, completionBlock: @escaping ApiResponseCompletion) {
        
        debugPrint("path: ", path)
        debugPrint("params: ", resource.parameters)
        debugPrint("keys: ", modelArray.map({$0.key}))
        debugPrint("fileData: ", modelArray.map({$0.data}))
        debugPrint("fileURL: ", modelArray.map({$0.url}))
        debugPrint("mimeType: ", modelArray.map({$0.mimeType}))
        debugPrint("fileName: ", modelArray.map({$0.fileName}))
        debugPrint("uploadType: ", uploadType)
        
        AF.upload(multipartFormData: { multipartFormData in
            
            if uploadType == .data {
                for model in modelArray {
                    multipartFormData.append(model.data!, withName: model.key, fileName: model.fileName, mimeType: model.mimeType.rawValue)
                }
            }else {//url
                for model in modelArray {
                    multipartFormData.append(model.url!, withName: model.key, fileName: model.fileName, mimeType: model.mimeType.rawValue)
                }
            }
            
            for (key, value) in resource.parameters ?? [:] {
                    multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
            }
        }, to: path, method: self.getHTTPMethodType(type: resource.method), headers: self.getHttpHeader(headers: resource.headers))
            .responseJSON { (response) in
                switch response.result {
                    
                case .success(let json):
                    debugPrint("API response is: ", json)
                    if resource.validator != nil {
                        resource.validator?.validateResponse(statusCode: response.response?.statusCode ?? -1, response: json, completionBlock: { (result) in
                            switch result {
                            case .success(let response):
                                completionBlock(.success(response))
                            case .failure(let error):
                                completionBlock(.failure(error))
                            }
                        })
                    }else {
                        let result = ApiResponseSuccessBlock(message: "", statusCode: response.response?.statusCode ?? -1, resultData: json)
                        completionBlock(.success(result))
                    }
                case .failure(let error):
                    debugPrint("API response error: ", error.localizedDescription)
                    let apiError = ApiResponseErrorBlock(message: error.localizedDescription)
                    completionBlock(.failure(apiError))
                }
        }
    }
    
    private func getHTTPMethodType(type:HTTPMethodType) -> HTTPMethod{
        switch type {
        case .get:
            return .get
        case .post:
            return .post
        case .put:
            return .put
        case .delete:
            return .delete
        default:
            return .get
            
        }
    }
    
    private func getURLEncoderType(type:URLEncodingType) -> ParameterEncoder{
        switch type {
        case .FORM:
            return URLEncodedFormParameterEncoder.init(encoder: URLEncodedFormEncoder(), destination: URLEncodedFormParameterEncoder.Destination.httpBody)
        case .QUERY:
            return URLEncodedFormParameterEncoder.init(encoder: URLEncodedFormEncoder(), destination: URLEncodedFormParameterEncoder.Destination.queryString)
        case .JSONENCODING:
            return JSONParameterEncoder.default
        default:
            return URLEncodedFormParameterEncoder.default
        }
        
    }
    
    private func getURLEncodingType(type:URLEncodingType) -> ParameterEncoding{
        switch type {
        case .FORM:
            return URLEncoding.httpBody
        case .QUERY:
            return URLEncoding.queryString
        case .JSONENCODING:
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
        
    }
    
    private func getHttpHeader(headers:[String:Any]?) -> HTTPHeaders? {
        guard let headers = headers else {
            return nil
        }
        
        var httpHeaders: HTTPHeaders = HTTPHeaders()
        for  (key,value) in headers {
            if let dictionary = value as? [String: Any] {
                let h1 = HTTPHeader.init(name: key, value: dictionary.jsonString() ?? "")
                httpHeaders.add(h1)
            }else {
                let h1 = HTTPHeader.init(name: key, value: value as? String ?? "")
                httpHeaders.add(h1)
            }
        }
        return httpHeaders
        
    }
    
    func createUrlRequest(path: String, resource: Resource) -> URLRequest {
        
        let url = URL(string: path)!
        var request = URLRequest(url: url)
        request.httpMethod = resource.method.rawValue
        debugPrint("Request method: ", resource.method.rawValue)
        debugPrint("Request parameters: ", resource.parameters ?? [:])
        if let parameters = resource.parameters {
            // ADD PARAMETERS
            do {
                let data = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                request.httpBody = data
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
        
        debugPrint("Request headers: ", resource.headers ?? [:])
        // ADD HEADERS
        for (key, value) in resource.headers ?? [:] {
            if let dictionary = value as? [String: Any] {
                request.setValue(dictionary.jsonString() ?? "", forHTTPHeaderField: key)
            }else if let stringValue = value as? String {
                request.setValue(stringValue, forHTTPHeaderField: key)
            }
        }
        
        return request
    }
        
    // MARK: - DOWNLOAD PDF
    func downloadPdf(from urlString: String, completionHandler:@escaping(String?, Bool)->()){

        guard let downloadURL = URL(string: urlString) else {
            return
        }
        let fileName = downloadURL.lastPathComponent
        
        let destinationPath: DownloadRequest.Destination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0];
            let fileURL = documentsURL.appendingPathComponent(fileName)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        debugPrint("Downloading file url: ", urlString)
        AF.download(urlString, to: destinationPath)
            .downloadProgress { progress in
                debugPrint(progress.completedUnitCount)
            }
            .responseData { response in
                debugPrint("response: \(response)")
                switch response.result{
                case .success:
                    if let filePath = response.fileURL {
                        completionHandler(filePath.absoluteString, true)
                    }else {
                        completionHandler(nil, false)
                    }
                case .failure:
                    completionHandler(nil, false)
                }

        }
    }
}
