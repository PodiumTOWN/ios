//
//  ABIDecoder.swift
//  ink
//
//  Created by Michael Jach on 06/04/2022.
//

import Foundation

indirect enum ABIType {
  case array(name: String, type: ABIType)
  case string(name: String)
  case uint(name: String)
  case tuple(name: String, types: [ABIType])
  case address(name: String)
  
  public var typeName: String {
    switch self {
    case .uint:
      return "uint"
    case .array:
      return "array"
    case .string:
      return "string"
    case .tuple:
      return "tuple"
    case .address:
      return "address"
    }
  }
  
  public var name: String {
    switch self {
    case .uint(let name):
      return name
    case .array(let name, _):
      return name
    case .string(let name):
      return name
    case .tuple(let name, _):
      return name
    case .address(let name):
      return name
    }
  }
  
  public var isDynamic: Bool {
    switch self {
    case .uint:
      return false
      
    case .array:
      return true
      
    case .string:
      return true
      
    case .tuple:
      return true
      
    case .address:
      return false
    }
  }
  
  public var length: Int {
    switch self {
    case .uint:
      return 64
      
    case .array:
      return 0
      
    case .string:
      return 0
      
    case .tuple:
      return 0
      
    case .address:
      return 64
    }
  }
}

class ABI {
  public static func decode(from hex: String, types: [ABIType]) -> [String: Any] {
    let hexString = hex.replacingOccurrences(of: "0x", with: "")
    var currentOffset = 0
    var result: [String: Any] = [:]
    types.forEach { currentType in
      if currentType.isDynamic {
        let decoded = decodeAt(offset: currentOffset, hex: hexString, type: currentType)
        currentOffset += 64
        result[currentType.name] = decoded
      } else {
        let decoded = decodeAt(offset: currentOffset, hex: hexString, type: currentType)
        currentOffset += currentType.length
        result[currentType.name] = decoded
      }
    }
    
    return result
  }
  
  static func decodeAt(offset: Int, hex: String, type: ABIType) -> Any {
    switch type {
    case .tuple(_, let types):
      let offset = Int(hex.substr(offset, 64)!, radix: 16)!
      let hexString = String(hex.dropFirst(offset * 2))
      return decode(from: hexString, types: types)
      
    case .uint:
      let hexString = String(hex.dropFirst(offset))
      let value = UInt(String(hexString.substr(0, type.length)!), radix: 16)!
      return value
      
    case .address:
      let hexString = String(hex.dropFirst(offset))
      let value = "0x" + String(hexString.substr(24, 40)!)
      return value
      
    case .string:
      let hexString = String(hex.dropFirst(offset))
      let offset = Int(hexString.substr(0, 64)!, radix: 16)!
      if let stringLengthHex = hex.substr(offset * 2, 64),
         let stringLength = Int(stringLengthHex, radix: 16),
         let stringData = hex.substr(offset * 2 + 64, stringLength * 2) {
        return stringData.hexToString()
      } else {
        return ""
      }
      
    case .array(_, let type):
      let hexString = String(hex.dropFirst(offset))
      let offset = Int(hexString.substr(0, 64)!, radix: 16)! * 2
      let arrayLength = Int(String(hex.substr(offset, 64)!), radix: 16)!
      if arrayLength > 0 {
        return (0..<arrayLength).map { i -> Any in
          return decodeAt(offset: i * 64, hex: String(hex.dropFirst(offset + 64)), type: type)
        }
      } else {
        return []
      }
    }
  }
}
