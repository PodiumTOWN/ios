//
//  EthereumAPI.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

import WalletConnectSwift
import Foundation
import UIKit
import WalletCore

class RPCApi {
  private func send(url: String, jsonBody: String, completion: @escaping (_ response: RPCResponse?, _ error: AppError?) -> ()) {
    let url = URL(string: url)
    var request = URLRequest(url: url!)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let data = jsonBody.data(using: .utf8)!
    
    request.httpBody = data
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let error = error {
        print("Error took place \(error)")
        return
      }
      guard let data = data else { return }
      do {
        let rpcResponse = try JSONDecoder().decode(RPCResponse.self, from: data)
        DispatchQueue.main.async {
          if let error = rpcResponse.error {
            switch(error.message) {
            case "replacement transaction underpriced":
              completion(nil, .underpriced)
              
            case "insufficient funds for gas * price + value":
              completion(nil, .noFunds)
              
            case "exceeds block gas limit":
              completion(nil, .exceedsLimit)
              
            case "transaction underpriced":
              completion(nil, .underpriced)
              
            case "execution reverted":
              completion(nil, .reverted)
              
            case "intrinsic gas too low":
              completion(nil, .gasTooLow)
              
            default:
              completion(nil, .general)
            }
          } else {
            completion(rpcResponse, nil)
          }
        }
      } catch {
        completion(nil, .rpcOffline)
      }
    }
    task.resume()
  }
  
  private func sendExtended(url: String, jsonBody: String, completion: @escaping (_ response: RPCTransactionResponse?, _ error: AppError?) -> ()) {
    let url = URL(string: url)
    var request = URLRequest(url: url!)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let data = jsonBody.data(using: .utf8)!
    
    request.httpBody = data
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let error = error {
        print("Error took place \(error)")
        return
      }
      guard let data = data else { return }
      do {
        let rpcResponse = try JSONDecoder().decode(RPCTransactionResponse.self, from: data)
        if let error = rpcResponse.error {
          switch(error.message) {
          case "replacement transaction underpriced":
            completion(nil, .underpriced)
            
          case "insufficient funds for gas * price + value":
            completion(nil, .noFunds)
            
          default:
            completion(nil, .general)
          }
        } else {
          completion(rpcResponse, nil)
        }
      } catch let jsonErr {
        print(jsonErr)
      }
    }
    task.resume()
  }
  
  func getGasPrice(url: String, userAddress: String, completion: @escaping (_ gasPrice: String) -> ()) {
    let json = "{ \"jsonrpc\": \"2.0\", \"method\": \"eth_gasPrice\", \"id\": 1, \"params\": [] }"
    
    self.send(
      url: url,
      jsonBody: json) { response, error  in
        if let result = response?.result {
          completion(result.replacingOccurrences(of: "0x", with: "").paddingLeft(toLength: 64, withPad: "0"))
        }
      }
  }
  
  func estimateGasPrice(environment: AppEnvironment, data: String, completion: @escaping (_ gasPrice: String) -> ()) {
    let json = "{ \"jsonrpc\": \"2.0\", \"method\": \"eth_estimateGas\", \"id\": 1, \"params\": [{\"to\": \"\(environment.userContractAddress)\",\"data\":\"\(data)\"}] }"
    
    self.send(
      url: environment.rpcUrl,
      jsonBody: json) { response, error  in
        if let result = response?.result {
          completion(result.replacingOccurrences(of: "0x", with: ""))
        }
      }
  }
  
  func getTransactionCount(url: String, userAddress: String, completion: @escaping (_ transactionCount: Int) -> ()) {
    let json = "{ \"jsonrpc\": \"2.0\", \"method\": \"eth_getTransactionCount\", \"id\": 1, \"params\": [\"\(userAddress)\", \"latest\"] }"
    
    self.send(
      url: url,
      jsonBody: json) { response, error  in
        if let result = response?.result {
          completion(result.hexaToDecimal)
        }
      }
  }
  
  func getStories(environment: AppEnvironment, publicKey: String, following: [String], completion: @escaping ([Story]?, RPCError?) -> Void) {
    if let abi = try? ABI.encodeFunctionCall("getStories", parameters: [
      .init(type: .array(.address, following.count), value: following)
    ]) {
      let json = "{ \"jsonrpc\": \"2.0\", \"method\": \"eth_call\", \"id\": 1, \"params\": [{ \"from\": \"\(publicKey)\", \"to\": \"\(environment.userContractAddress)\", \"data\": \"\(abi)\" }, \"latest\"] }"
      
      self.send(
        url: environment.rpcUrl,
        jsonBody: json) { response, error  in
          if let result = response?.result {
            let decoded = ABI.decode(from: result, types: [
              .array(name: "root", type: .tuple(name: "story", types: [
                .array(name: "stories", type: .tuple(name: "story", types: [
                  .uint(name: "index"),
                  .address(name: "owner"),
                  .string(name: "text"),
                  .array(name: "images", type: .string(name: "element")),
                  .string(name: "transactionHash")
                ])),
                .tuple(name: "profile", types: [
                  .uint(name: "index"),
                  .address(name: "userAddress"),
                  .string(name: "username"),
                  .string(name: "avatar"),
                  .array(name: "following", type: .address(name: "element")),
                  .string(name: "bio")
                ])
              ]))
            ])
            
            var returnData: [Story] = []
            if let storiesData = decoded["root"] as? [[String: Any]] {
              storiesData.forEach({ story in
                if let stories = story["stories"] as? [[String: Any]],
                   let profile = story["profile"] as? [String: Any],
                   let profileModel = try? Profile(dictionary: profile) {
                  stories.forEach { innerStory in
                    if let story = try? Story(dictionary: innerStory) {
                      var storyTo = story
                      storyTo.profile = profileModel
                      returnData.append(storyTo)
                    }
                  }
                }
              })
            }
            
            completion(
              returnData,
              nil
            )
          } else {
            completion([], nil)
          }
        }
    } else {
      completion([], nil)
    }
  }
  
  func getProfile(environment: AppEnvironment, publicKey: String, privateKey: Data?,  completion: @escaping (Profile?, AppError?) -> Void) {
    if let abi = try? ABI.encodeFunctionCall("getUser", parameters: [.init(type: .address, value: publicKey)]) {
      let json = "{ \"jsonrpc\": \"2.0\", \"method\": \"eth_call\", \"id\": 1, \"params\": [{ \"from\": \"\(publicKey)\", \"to\": \"\(environment.userContractAddress)\", \"data\": \"\(abi)\" }, \"latest\"] }"
      
      self.send(
        url: environment.rpcUrl,
        jsonBody: json) { response, error  in
          if let result = response?.result {
            let decoded = ABI.decode(from: result, types: [
              .tuple(name: "userStruct", types: [
                .uint(name: "index"),
                .address(name: "userAddress"),
                .string(name: "username"),
                .string(name: "avatar"),
                .array(name: "following", type: .address(name: "element")),
                .string(name: "bio")
              ])])
            if let profile = try? Profile(dictionary: decoded["userStruct"] as! [String : Any]) {
              var mutated = profile
              mutated.userAddress = publicKey
              mutated.privateKey = privateKey
              completion(
                mutated,
                nil
              )
            }
          } else if let error = error, error != .reverted {
            completion(
              nil,
              error
            )
          } else {
            completion(
              Profile(
                userAddress: publicKey,
                privateKey: privateKey
              ),
              nil
            )
          }
        }
    }
    else {
      completion(
        Profile(
          userAddress: publicKey,
          privateKey: privateKey
        ),
        nil
      )
    }
  }
  
  func getProfiles(environment: AppEnvironment, publicKey: String, privateKey: Data?,  completion: @escaping ([Profile]?, AppError?) -> Void) {
    if let abi = try? ABI.encodeFunctionCall("getProfiles", parameters: []) {
      let json = "{ \"jsonrpc\": \"2.0\", \"method\": \"eth_call\", \"id\": 1, \"params\": [{ \"from\": \"\(publicKey)\", \"to\": \"\(environment.userContractAddress)\", \"data\": \"\(abi)\" }, \"latest\"] }"
      
      self.send(
        url: environment.rpcUrl,
        jsonBody: json) { response, error  in
          if let result = response?.result {
            let decoded = ABI.decode(from: result, types: [
              .array(name: "profiles", type: .tuple(name: "userStruct", types: [
                .uint(name: "index"),
                .address(name: "userAddress"),
                .string(name: "username"),
                .string(name: "avatar"),
                .array(name: "following", type: .address(name: "element")),
                .string(name: "bio")
              ]))
            ])
            
            if let profiles = decoded["profiles"] as? [[String: Any]] {
              let profiles = profiles.compactMap { profileDict in
                return try? Profile(dictionary: profileDict)
              }
              
              completion(
                profiles,
                nil
              )
            }
          } else if let error = error, error != .reverted {
            completion(
              nil,
              error
            )
          } else {
            completion(
              [],
              nil
            )
          }
        }
    }
    else {
      completion(
        [],
        nil
      )
    }
  }
  
  func addStory(environment: AppEnvironment, publicKey: String, privateKey: Data?, story: Story, completion: @escaping (Story?, AppError?) -> Void) {
    if let abi = try? ABI.encodeFunctionCall("addStory", parameters: [
      .init(type: .string, value: story.text),
      .init(type: .array(.string, nil), value: story.images),
      .init(type: .uint256, value: story.timestamp),
    ]) {
      let tx = Client.Transaction(
        from: publicKey,
        to: environment.userContractAddress,
        data: abi,
        gas: "0xF4240",
        gasPrice: "0x1C0D48521E",
        value: nil,
        nonce: nil,
        type: nil,
        accessList: nil,
        chainId: nil,
        maxPriorityFeePerGas: nil,
        maxFeePerGas: nil
      )
      
      var mutatedStory = story
      
      if let privateKey = privateKey {
        getGasPrice(
          url: environment.rpcUrl,
          userAddress: publicKey) { gasPrice in
            self.getTransactionCount(
              url: environment.rpcUrl,
              userAddress: publicKey) { transactionCount in
                let signerInput = EthereumSigningInput.with {
                  $0.chainID = Data(hex: String(environment.chainId, radix: 16))
                  $0.gasPrice = Data(hex: gasPrice)
                  $0.gasLimit = Data(hex: "0927C0")
                  $0.toAddress = environment.userContractAddress
                  $0.nonce = Data(hex: String(format:"%02X", transactionCount))
                  $0.transaction = EthereumTransaction.with {
                    $0.contractGeneric = .with {
                      $0.data = Data(abi.hexToBytes())
                    }
                  }
                  $0.privateKey = privateKey
                }
                
                let output: EthereumSigningOutput = AnySigner.sign(input: signerInput, coin: .ethereum)
                
                let json = "{ \"jsonrpc\": \"2.0\", \"method\": \"eth_sendRawTransaction\", \"id\": 1, \"params\": [\"0x\(output.encoded.hexString)\"] }"
                self.send(
                  url: environment.rpcUrl,
                  jsonBody: json) { response, error  in
                    if let transactionHash = response?.result {
                      mutatedStory.transaction = Transaction(
                        address: transactionHash,
                        type: .addStory
                      )
                      completion(mutatedStory, nil)
                    } else if let error = error {
                      completion(nil, error)
                    }
                  }
              }
          }
      } else {
        try? environment.walletConnect.client.eth_sendTransaction(
          url: environment.walletConnect.session.url,
          transaction: tx) { response in
            if let transactionHash = try? response.result(as: String.self) {
              mutatedStory.transaction = Transaction(
                address: transactionHash,
                type: .addStory
              )
              completion(mutatedStory, nil)
            }
          }
      }
    } else {
      completion(nil, .general)
    }
  }
  
  func updateProfile(environment: AppEnvironment, profile: Profile, completion: @escaping (Profile?, AppError?) -> Void) {
    if let abi = try? ABI.encodeFunctionCall("updateProfile", parameters: [
      .init(type: .string, value: profile.username),
      .init(type: .string, value: profile.avatar),
      .init(type: .array(.address, nil), value: profile.following),
      .init(type: .string, value: profile.bio),
    ]) {
      var mutatedProfile = profile
      
      if let privateKey = profile.privateKey {
        self.getGasPrice(
          url: environment.rpcUrl,
          userAddress: profile.userAddress) { gasPrice in
            self.getTransactionCount(
              url: environment.rpcUrl,
              userAddress: profile.userAddress) { transactionCount in
                let signerInput = EthereumSigningInput.with {
                  $0.chainID = Data(hex: String(environment.chainId, radix: 16))
                  $0.gasPrice = Data(hex: gasPrice)
                  $0.gasLimit = Data(hex: "07A120")
                  $0.toAddress = environment.userContractAddress
                  $0.nonce = Data(hex: String(format:"%02X", transactionCount))
                  $0.transaction = EthereumTransaction.with {
                    $0.contractGeneric = .with {
                      $0.data = Data(abi.hexToBytes())
                    }
                  }
                  $0.privateKey = privateKey
                }
                
                let output: EthereumSigningOutput = AnySigner.sign(input: signerInput, coin: .ethereum)
                
                let json = "{ \"jsonrpc\": \"2.0\", \"method\": \"eth_sendRawTransaction\", \"id\": 1, \"params\": [\"0x\(output.encoded.hexString)\"] }"
                self.send(
                  url: environment.rpcUrl,
                  jsonBody: json) { response, error  in
                    if let transactionHash = response?.result {
                      mutatedProfile.transaction = Transaction(
                        address: transactionHash,
                        type: .updateProfile
                      )
                      completion(mutatedProfile, nil)
                    } else if let error = error {
                      completion(nil, error)
                    }
                  }
              }
          }
      } else {
        let tx = Client.Transaction(
          from: profile.userAddress,
          to: environment.userContractAddress,
          data: abi,
          gas: "0x7A120",
          gasPrice: "0x1C0D48521E",
          value: nil,
          nonce: nil,
          type: nil,
          accessList: nil,
          chainId: nil,
          maxPriorityFeePerGas: nil,
          maxFeePerGas: nil
        )
        
        try? environment.walletConnect.client.eth_sendTransaction(
          url: environment.walletConnect.session.url,
          transaction: tx) { response in
            if let transactionHash = try? response.result(as: String.self) {
              mutatedProfile.transaction = Transaction(
                address: transactionHash,
                type: .updateProfile
              )
              completion(mutatedProfile, nil)
            }
          }
      }
    } else {
      completion(nil, .general)
    }
  }
  
  func getTransactionDetails(environment: AppEnvironment, transaction: Transaction, completion: @escaping (Transaction?, RPCError?) -> Void) {
    let json = "{ \"jsonrpc\": \"2.0\", \"method\": \"eth_getTransactionReceipt\", \"id\": 1, \"params\": [\"\(transaction.address)\"] }"
    self.sendExtended(
      url: environment.rpcUrl,
      jsonBody: json) { response, error  in
        if let result = response?.result {
          let transaction = Transaction(
            address: result.transactionHash,
            type: transaction.type,
            status: result.status
          )
          completion(transaction, nil)
        } else {
          completion(transaction, nil)
        }
      }
  }
}
