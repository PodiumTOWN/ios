//
//  ABIEncoder.swift
//  ink
//
//  Created by Michael Jach on 06/04/2022.
//

struct Segment {
  let type: ABIParamType
  let encodedValue: String
  
  var staticLength: Int {
    if !type.isDynamic {
      return encodedValue.count / 2
    }
    return 32
  }
}

extension ABI {
  public static func encodeFunctionCall(_ name: String, parameters: [ABIInputParam]) throws -> String {
    let segments = parameters.map { param -> Segment in
      switch(param.type) {
      case .uint:
        let data = String(param.value as! UInt, radix: 16).paddingLeft(toLength: 64, withPad: "0")
        
        return Segment(type: .uint, encodedValue: data)
      case .uint256:
        let data = String(param.value as! UInt, radix: 16).paddingLeft(toLength: 64, withPad: "0")
        return Segment(type: .uint, encodedValue: data)
        
      case .string:
        if let data = (param.value as? String)?.abiEncode(dynamic: true) {
          return Segment(type: .string, encodedValue: data)
        } else {
          return Segment(type: .string, encodedValue: "".abiEncode(dynamic: true)!)
        }
        
      case .address:
        let data = (param.value as! String).replacingOccurrences(of: "0x", with: "").paddingLeft(toLength: 64, withPad: "0")
        return Segment(type: .address, encodedValue: data)
        
      case .array(let type, let size):
        let data = (param.value as! Array<String>).abiEncode(dynamic: size == nil ? true : false)!
        return Segment(type: .array(type, size), encodedValue: data)
        
      default:
        return Segment(type: .address, encodedValue: "none")
      }
    }
    
    let dynamicOffsetStart = segments.map { $0.staticLength }.reduce(0, +)
    // reduce to static string and dynamic string
    let (staticValues, dynamicValues) = segments.reduce(("", ""), { result, segment in
      var (staticParts, dynamicParts) = result
      if !segment.type.isDynamic {
        staticParts += segment.encodedValue
      } else {
        // static portion for dynamic value represents offset in bytes
        // offset is start of dynamic segment + length of current dynamic portion (in bytes)
        let offset = dynamicOffsetStart + (result.1.count / 2)
        staticParts += String(offset, radix: 16).paddingLeft(toLength: 64, withPad: "0")
        dynamicParts += segment.encodedValue
      }
      return (staticParts, dynamicParts)
    })
    // combine as single string (static parts, then dynamic parts)
    let encodedParams = staticValues + dynamicValues
    
    let paramTypes = parameters.map({ $0.type.rawValue }).joined(separator: ",")
    let signatureString = encodeFunctionSignature("\(name)(\(paramTypes))")
    return signatureString + encodedParams
  }
  
  public static func encodeFunctionSignature(_ name: String) -> String {
    return "0x" + String(name.sha3(.keccak256).prefix(8))
  }
}
