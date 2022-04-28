//
//  String+Extensions.swift
//  ink
//
//  Created by Michael Jach on 06/04/2022.
//

import Foundation

extension String {
  public func split(every: Int, backwards: Bool = false) -> [String] {
    var result = [String]()
    
    for i in stride(from: 0, to: self.count, by: every) {
      switch backwards {
      case true:
        let endIndex = self.index(self.endIndex, offsetBy: -i)
        let startIndex = self.index(endIndex, offsetBy: -every, limitedBy: self.startIndex) ?? self.startIndex
        result.insert(String(self[startIndex..<endIndex]), at: 0)
      case false:
        let startIndex = self.index(self.startIndex, offsetBy: i)
        let endIndex = self.index(startIndex, offsetBy: every, limitedBy: self.endIndex) ?? self.endIndex
        result.append(String(self[startIndex..<endIndex]))
      }
    }
    
    return result
  }
  
  func substr(_ offset: Int,  _ length: Int) -> String? {
    guard offset + length <= self.count else { return nil }
    let start = index(startIndex, offsetBy: offset)
    let end = index(start, offsetBy: length > 0 ? length : 0)
    return String(self[start..<end])
  }
  
  func paddingLeft(toLength length: Int, withPad character: Character) -> String {
    if self.count < length {
      return String(repeatElement(character, count: length - self.count)) + self
    } else {
      return String(self.prefix(length))
    }
  }
}

extension String {
  public init?(hexString: String) {
    if let data = Data(hexString: hexString) {
      self.init(data: data, encoding: .utf8)
    } else {
      return nil
    }
  }
  
  func hexToString() -> String {
    if let result =  String(data: Data(hex: self), encoding: .utf8) {
      return result
    } else {
      return ""
    }
  }
  
  func abiEncode(dynamic: Bool) -> String? {
    if dynamic {
      return Data(self.utf8).abiEncodeDynamic()
    }
    
    return self.replacingOccurrences(of: "0x", with: "").paddingLeft(toLength: 64, withPad: "0")
  }
  
  func padding(toMultipleOf base: Int, withPad character: Character) -> String {
    // round up to the nearest multiple of base
    let newLength = Int(ceil(Double(count) / Double(base))) * base
    return self.padding(toLength: newLength, withPad: String(character), startingAt: 0)
  }
  
  func hexToBytes() -> [UInt8] {
    var value = self
    if self.count % 2 > 0 {
      value = "0" + value
    }
    let bytesCount = value.count / 2
    return (0..<bytesCount).compactMap({ i in
      let offset = i * 2
      if let str = value.substr(offset, 2) {
        return UInt8(str, radix: 16)
      }
      return nil
    })
  }
}

extension StringProtocol {
  func dropping<S: StringProtocol>(prefix: S) -> SubSequence { hasPrefix(prefix) ? dropFirst(prefix.count) : self[...] }
  var hexaToDecimal: Int { Int(dropping(prefix: "0x"), radix: 16) ?? 0 }
}
