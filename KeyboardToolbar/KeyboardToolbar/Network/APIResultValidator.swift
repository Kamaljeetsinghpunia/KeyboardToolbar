//
//  APIResultValidator.swift
//

import Foundation

struct ApiResponseSuccessBlock{
    var message: String
    var statusCode: Int
    var resultData: Any?
}

struct ApiResponseErrorBlock: Error {
    var message: String
  //  var statusCode: String
}

typealias ApiResponseCompletion = ((Result<ApiResponseSuccessBlock, ApiResponseErrorBlock>) -> ())
typealias SocketResponseCompletion = ((Result<[String: Any], ApiResponseErrorBlock>) -> ())

protocol APIResultValidatorApi{
    func validateResponse(statusCode: Int, response: Any?, completionBlock: @escaping ApiResponseCompletion)
    func getApiError(result:String?) -> ApiResponseErrorBlock
    func getApiResponse(result:Any?, statusCode: Int) -> ApiResponseSuccessBlock
}

extension APIResultValidatorApi{
    
    func getApiError(result:String?) -> ApiResponseErrorBlock{
        let apiError = ApiResponseErrorBlock.init(message: result ?? "Error description not available")
        return apiError
    }
    
    func getApiResponse(result:Any?, statusCode: Int) -> ApiResponseSuccessBlock{
        var apiResponse = ApiResponseSuccessBlock.init(message: "", statusCode: statusCode, resultData: result)
        if let responseDict = result as? [String:AnyObject] {
            
            if let msg = responseDict["message"] as? String {
                apiResponse.message = msg
            }

            apiResponse.resultData = responseDict as Any
        }
        return apiResponse
    }
}

struct APIJSONResultValidator: APIResultValidatorApi{
    
    func validateResponse(statusCode: Int, response: Any?, completionBlock: @escaping ApiResponseCompletion) {

        if statusCode == 200 || statusCode == 0  {
            if let response = response  as? [String: Any] { //For response as dictionary
                completionBlock(.success(self.getApiResponse(result: response, statusCode: statusCode)))
            } else if let response = response as? [[String: Any]] { //For response as array of dictionary
                completionBlock(.success(self.getApiResponse(result: response, statusCode: statusCode)))
            } else {
                completionBlock(.failure(self.getApiError(result: "Invalid JSON. Line: 61. Class: APIResultValidator")))
            }
        } else {
            if let response = response  as? [String: Any] {
                let message = response["statusMessage"] as? String ?? LocalizedStringEnum.somethingWentWrong.localized
                completionBlock(.failure(self.getApiError(result: message)))
            }else {
                completionBlock(.failure(self.getApiError(result: "Invalid JSON. Line: 69. Class: APIResultValidator")))
            }
        }
    }
}

struct APIDataResultValidator: APIResultValidatorApi {
    
    func validateResponse(statusCode: Int, response: Any?, completionBlock: @escaping ApiResponseCompletion) {
        
        var jsonResponse: [String: Any]?
        if let data = response as? Data {
            do {
                jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                debugPrint("API response is: ", jsonResponse ?? [:])
            }catch {
                debugPrint("Error converting data to JSON: ", error.localizedDescription)
            }
        }
        
        let responseStatusCode = (jsonResponse?["statusCode"] as? Int) ?? 400
        if statusCode == 200 && responseStatusCode == 200 {
            var apiResponse = self.getApiResponse(result: jsonResponse, statusCode: statusCode)
            apiResponse.resultData = response
            completionBlock(.success(apiResponse))
        } else {
            if jsonResponse != nil {
                let message = jsonResponse?["message"] as? String ?? LocalizedStringEnum.somethingWentWrong.localized
                completionBlock(.failure(self.getApiError(result: message)))
            }else {
                completionBlock(.failure(self.getApiError(result: "Invalid JSON. Line: 101. Class: APIResultValidator")))
            }
        }
    }
    
}
