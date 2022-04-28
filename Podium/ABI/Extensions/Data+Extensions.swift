//
//  Data+Extensions.swift
//  ink
//
//  Created by Michael Jach on 06/04/2022.
//

import Foundation

extension Data {
  public init?(hexString: String) {
    let lengthString = hexString.substr(0, 64)
    let valueString = String(hexString.dropFirst(64))
    guard let string = lengthString, let length = Int(string, radix: 16), length > 0 else { return nil }
    let bytes = valueString.hexToBytes()
    let trimmedBytes = bytes.prefix(length)
    self.init(trimmedBytes)
  }
  
  public func abiEncodeDynamic() -> String? {
    // number of bytes
    let length = String(self.count, radix: 16).paddingLeft(toLength: 64, withPad: "0")
    // each bytes, padded right
    let value = map { String(format: "%02x", $0) }.joined().padding(toMultipleOf: 64, withPad: "0")
    return length + value
  }
}
