//
//  Transaction.swift
//  Podium
//
//  Created by Michael Jach on 19/04/2022.
//

enum TransactionType: String, Codable {
  case updateProfile = "Update profile"
  case addStory = "Add post"
}

struct Transaction: Equatable, Identifiable, Codable {
  var id: String { address }
  var address: String
  var type: TransactionType
  var status: String? = "-1"
}
