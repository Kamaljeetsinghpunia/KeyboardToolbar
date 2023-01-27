//
//  NetworkRequest.swift
//

import Foundation

public struct HTTPMethodType: RawRepresentable, Equatable, Hashable {
    
    /// `DELETE` method.
    public static let delete = HTTPMethodType(rawValue: "DELETE")
    /// `GET` method.
    public static let get = HTTPMethodType(rawValue: "GET")
    public static let post = HTTPMethodType(rawValue: "POST")
    /// `PUT` method.
    public static let put = HTTPMethodType(rawValue: "PUT")
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public enum URLEncodingType{
    case FORM
    case QUERY
    case JSONENCODING
    case FileUpload
    case URLENCODING
}

public enum NetworkErrorReason: Error {
    case FailureErrorCode(code: Int, message: String)
    case InternetNotReachable
    case UnAuthorizedAccess
    case Other
}

public enum MimeType: String {
    case image = "image/png"
    case video = "video/mp4"
}

public enum MultipartUploadType {
    case data
    case url
}

enum ApiResultType {
    case json
    case data
}

struct Resource {
    let method: HTTPMethodType
    let parameters: [String : Any]?
    let encoding: URLEncodingType
    let headers: [String:Any]?
    let validator: APIResultValidatorApi?
    let responseType: ApiResultType
}

protocol APIService {
    var path: String { get }
    var resource: Resource { get }
}

extension APIService {
    func urlRequest(completionBlock: @escaping ApiResponseCompletion) {
        //We can chanage this alamofire dependency any time.
        AlamofireNetworkManager().urlRequest(path: self.path, resource: self.resource, completionBlock: completionBlock)
    }
    
    func request(completionBlock: @escaping ApiResponseCompletion) {
        AlamofireNetworkManager().request(path: self.path, resource: self.resource, completionBlock: completionBlock)
    }
    
    func requestMultipart(modelArray: [MultipartModel], uploadType: MultipartUploadType, completionBlock: @escaping ApiResponseCompletion) {
        AlamofireNetworkManager().multipartRequest(path: self.path, resource: self.resource, modelArray: modelArray, uploadType: uploadType, completionBlock: completionBlock)
    }
}
