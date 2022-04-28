//
//  Profile.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

import UIKit

struct Profile: Equatable, Identifiable {
  var id: String { userAddress }
  var userAddress: String
  var username: String?
  var following: [String] = []
  var avatar: String?
  var bio: String?
  var transaction: Transaction?
  var privateKey: Data?
}

extension Profile: Codable {
  init(dictionary: [String: Any]) throws {
    self = try JSONDecoder().decode(
      Profile.self,
      from: JSONSerialization.data(withJSONObject: dictionary)
    )
  }
}
