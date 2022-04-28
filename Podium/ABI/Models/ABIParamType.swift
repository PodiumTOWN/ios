//
//  ABIParamType.swift
//  ink
//
//  Created by Michael Jach on 06/04/2022.
//

indirect enum ABIParamType {
  case uint
  case uint256
  case string
  case address
  case array(ABIParamType, Int?)
  case tuple([ABIParam])
  
  public var staticPartLength: UInt {
    switch self {
    case .array(let type, let length):
      if let length = length {
        return UInt(length) * type.staticPartLength
      }
      return 32
      
    case .address:
      return 40
      
    default:
      return 32
    }
  }
  
  public var components: [ABIParam] {
    switch self {
    case .tuple(let params):
      return params
      
    case .array(let params, let size):
      return [ABIParam(name: "element", type: params)]
      
    case .string:
      return [ABIParam(name: "element", type: .string)]
      
    default:
      return []
    }
  }
  
  public var length: Int {
    switch self {
    case .uint:
      return 64
      
    default:
      return 64
    }
  }
  
  public var isDynamic: Bool {
    switch self {
    case .tuple(let types):
      return types.count > 1 || types.filter { $0.type.isDynamic }.count > 0
    case .address:
      return false
    case .uint:
      return false
    case .uint256:
      return false
    case .string:
      return true
    case .array(let type, let length):
      return type.isDynamic || length == nil
    }
  }
  
  public var stringType: String {
    switch self {
    case .tuple:
      return "tuple"
    case .address:
      return "address"
    case .uint:
      return "uint"
    case .uint256:
      return "uint256"
    case .string:
      return "string"
    case .array:
      return "array"
    }
  }
  
  public var rawValue: String {
    switch self {
    case .tuple(let params):
      return params.map({ $0.type.rawValue }).joined(separator: ",")
    case .address:
      return "address"
    case .uint:
      return "uint"
    case .uint256:
      return "uint256"
    case .string:
      return "string"
    case .array(let type):
      return "\(type.0.stringType)[]"
    }
  }
}
