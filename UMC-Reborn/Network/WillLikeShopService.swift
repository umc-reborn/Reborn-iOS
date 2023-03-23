//
//  WillLikeShopService.swift
//  UMC-Reborn
//
//  Created by nayeon  on 2023/02/25.
//

import Foundation
import Alamofire

class WillLikeShopService {
    
    static let shared = WillLikeShopService()
    private init() {}
    var jwt = UserDefaults.standard.string(forKey: "userJwt")!
    
    func getLikeShop(completion: @escaping (NetworkResult<Any>) -> Void) {
        let url: String! = APIConstants.willLikeshopURL
             let header: HTTPHeaders = ["Content-type": "application/json",
                                        "X-ACCESS-TOKEN": "\(jwt)"]
                 

             let dataRequest = AF.request(
                url, method: .get,
                parameters: nil,
                encoding: URLEncoding.default,
                headers: header
             )
        
             dataRequest.responseData { response in
                 dump(response)
                 switch response.result {
                 case .success:
                     guard let statusCode = response.response?.statusCode else { return }
                     dump(statusCode)
                     guard let value = response.value else { return }
                     dump(value)
                     let networkResult = self.judgeStatus(by: statusCode, value, WillLikeShopModel.self)
                     completion(networkResult)

                 case .failure:
                     completion(.networkFail)
                    
                 }
             }
         }
    
    func updateLikes(idPost: String, like: Bool)-> Void{
        
        let url: String! = APIConstants.willLikeshopURL
             let header: HTTPHeaders = ["Content-type": "application/json",
                                        "X-ACCESS-TOKEN": "\(jwt)"]
        let params = ["hasJjim" : like]
        AF.request(url, method: .patch, parameters: params, encoding: JSONEncoding.default, headers: header).validate().responseJSON{(response) in print("response: ", response)}
    }
    
//    func updateMessage(params: [String : AnyObject]!, message_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
//    {
//        // TODO: Updates message data Returns code 200 and {result: “success”} if message successfully updated.
//        // The corresponding API is documented here:
//        // https://geoconfess.herokuapp.com/apidoc/V1/messages/update.html
//
//        let url: String! = APIConstants.willLikeshopURL
//
//        Alamofire.request(.PATCH, url, parameters: params).responseJSON {
//            response in
//            switch response.result {
//            case .Success:
//                completion(response: response.result.value, error: nil)
//            case .Failure(let error):
//                logError("Update message error: \(error)")
//                completion(response: nil, error: error)
//            }
//        }
//    }
    
    

         private func judgeStatus<T:Codable> (by statusCode: Int, _ data: Data, _ type: T.Type) -> NetworkResult<Any> {
             let decoder = JSONDecoder()
             guard let decodedData = try? decoder.decode(type.self, from: data)
             else { return .pathErr}

             switch statusCode {
             case 200 ..< 300: return .success(decodedData as Any)
             case 400 ..< 500: return .pathErr
             case 500: return .serverErr
             default: return .networkFail
             }
         }
   }
