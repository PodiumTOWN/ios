//
//  RPCResponse.swift
//  ink
//
//  Created by Michael Jach on 03/04/2022.
//

struct RPCResponseError: Codable {
  var code: Int
  var message: String
}

struct RPCResponse: Codable {
  var jsonrpc: String
  var result: String?
  var error: RPCResponseError?
  var id: Int?
}

struct RPCTransactionResponse: Codable {
  struct RPCTransaction: Codable {
    var transactionHash: String
    var status: String
  }
  
  var jsonrpc: String
  var result: RPCTransaction?
  var error: RPCResponseError?
  var id: Int?
}
