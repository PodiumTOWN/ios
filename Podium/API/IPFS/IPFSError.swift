//
//  IPFSError.swift
//  ink
//
//  Created by Michael Jach on 09/04/2022.
//

enum IPFSError: Error, Equatable {
  case ipfsOffline
  case generic
}

extension IPFSError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .ipfsOffline:
      return "IPFS offline."
      
    case .generic:
      return "Generic error."
    }
  }
}
