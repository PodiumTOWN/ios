//
//  IPFSApi.swift
//  ink
//
//  Created by Michael Jach on 09/04/2022.
//

import Foundation

class IPFSApi {
  func uploadPhoto(url: String, imageData: Data, completion: @escaping (_ response: IPFSResponse?, _ error: IPFSError?) -> ()) {
    var request = URLRequest(url: URL(string: "\(url)/add")!)
    
    let boundary = UUID().uuidString
    request.httpMethod = "POST"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
    var data = Data()
    data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
    data.append("Content-Disposition: form-data; name=\"image\"; filename=\"user.png\"\r\n".data(using: .utf8)!)
    data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
    data.append(imageData)
    
    data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
    
    URLSession.shared.uploadTask(with: request, from: data, completionHandler: { responseData, response, error in
      if let responseData = responseData,
         let metadataResponse = try? JSONDecoder().decode(IPFSResponse.self, from: responseData) {
        DispatchQueue.main.async {
          completion(metadataResponse, nil)
        }
      }
      
      if error != nil {
        DispatchQueue.main.async {
          completion(nil, .ipfsOffline)
        }
      }
    }).resume()
  }
  
  func uploadText(url: String, text: String, completion: @escaping (_ response: IPFSResponse?, _ error: IPFSError?) -> ()) {
    var request = URLRequest(url: URL(string: "\(url)/add")!)
    
    let boundary = UUID().uuidString
    request.httpMethod = "POST"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
    var data = Data()
    data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
    data.append("Content-Disposition: form-data; name=\"file\"; filename=\"user.txt\"\r\n".data(using: .utf8)!)
    data.append("Content-Type: text/plain\r\n\r\n".data(using: .utf8)!)
    data.append(text.data(using: .utf8)!)
    
    data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
    
    URLSession.shared.uploadTask(with: request, from: data, completionHandler: { responseData, response, error in
      if let responseData = responseData,
         let metadataResponse = try? JSONDecoder().decode(IPFSResponse.self, from: responseData) {
        DispatchQueue.main.async {
          completion(metadataResponse, nil)
        }
      }
      
      if error != nil {
        DispatchQueue.main.async {
          completion(nil, .ipfsOffline)
        }
      }
    }).resume()
  }
  
  func downloadPhoto(url: String, hash: String, completion: @escaping (_ response: Data?, _ error: IPFSError?) -> ()) {
    URLSession.shared.dataTask(with: URL(string: "\(url)/ipfs/\(hash)")!) { data, response, error in
      if error != nil {
        DispatchQueue.main.async {
          completion(nil, .generic)
        }
      } else if let data = data {
        DispatchQueue.main.async {
          completion(data, nil)
        }
      }
    }.resume()
  }
}
