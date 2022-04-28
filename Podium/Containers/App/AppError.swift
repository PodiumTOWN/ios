//
//  AppError.swift
//  Podium
//
//  Created by Michael Jach on 21/04/2022.
//

enum AppError: Error, Codable {
  case general
  case underpriced
  case noFunds
  case exceedsLimit
  case reverted
  case rpcOffline
  case gasTooLow
}

extension AppError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .rpcOffline:
      return "Ethereum node offline."
      
    case .reverted:
      return "Transaction reverted."
      
    case .underpriced:
      return "Transaction underpriced."
      
    case .noFunds:
      return "Insufficient funds."
      
    case .exceedsLimit:
      return "Exceeds block gas limit."
      
    case .gasTooLow:
      return "Intrinsic gas too low."
      
    case .general:
      return "Generic error."
    }
  }
}
