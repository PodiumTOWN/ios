//
//  Array+Extensions.swift
//  ink
//
//  Created by Michael Jach on 08/04/2022.
//

import Foundation

public protocol ABIEncodable {
  /// Encode to hex string
  ///
  /// - Parameter dynamic: Hopefully temporary workaround until dynamic conditional conformance works
  /// - Returns: Solidity ABI encoded hex string
  func abiEncode(dynamic: Bool) -> String?
}

extension Array {
  public func abiEncode(dynamic: Bool) -> String? {
    if dynamic {
      return abiEncodeDynamic()
    }
    
    let offset = "20".paddingLeft(toLength: 64, withPad: "0")
    let length = String(self.count, radix: 16).paddingLeft(toLength: 64, withPad: "0")
    return offset + length + self.compactMap { ($0 as! String).abiEncode(dynamic: false) }.joined()
  }
  
  public func abiEncodeDynamic() -> String? {
    // get values
    let values = self.compactMap { value -> String? in
      let value = value as? String
      if let value = value {
        return value.abiEncode(dynamic: true)
      } else {
        return value
      }
    }
    // number of elements in the array, padded left
    let length = String(values.count, radix: 16).paddingLeft(toLength: 64, withPad: "0")
    // values, joined with no separator
    
    let offsets = values
      .map({ $0.count})
      .reduce("") { partialResult, hex in
        if partialResult == "" {
          return String(values.count * 32, radix: 16).paddingLeft(toLength: 64, withPad: "0")
        } else {
          let length = partialResult + String(hex - 32, radix: 16).paddingLeft(toLength: 64, withPad: "0")
          return length
        }
      }
    
    return length + offsets + values.joined()
  }
}

extension Array: ABIEncodable where Element: ABIEncodable {
  
  public func abiEncode(dynamic: Bool) -> String? {
    if dynamic {
      return abiEncodeDynamic()
    }
    // values encoded, joined with no separator
    return self.compactMap { $0.abiEncode(dynamic: false) }.joined()
  }
  
  public func abiEncodeDynamic() -> String? {
    // get values
    let values = self.compactMap { value -> String? in
      return value.abiEncode(dynamic: true)
    }
    // number of elements in the array, padded left
    let length = String(values.count, radix: 16).paddingLeft(toLength: 64, withPad: "0")
    // values, joined with no separator
    return length + values.joined()
  }
}
