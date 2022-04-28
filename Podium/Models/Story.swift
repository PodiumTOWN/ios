//
//  Story.swift
//  ink
//
//  Created by Michael Jach on 04/04/2022.
//

import Foundation

struct Story: Equatable, Identifiable {
  var id: UInt { index }
  var index: UInt
  var owner: String
  var text: String?
  var images: [String] = []
  var profile: Profile?
  var transaction: Transaction?
  var timestamp: UInt?
}

extension Story: Codable {
  init(dictionary: [String: Any]) throws {
    self = try JSONDecoder().decode(
      Story.self,
      from: JSONSerialization.data(withJSONObject: dictionary)
    )
  }
}
