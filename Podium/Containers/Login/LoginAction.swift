//
//  LoginAction.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

import Foundation

enum LoginAction {
  case connectMnemonic
  case connect
  case didConnect(Result<(String, Data?), AppError>)
  case getProfile(publicKey: String, privateKey: Data?)
  case didGetProfile(Result<Profile, AppError>)
  case presentRawLogin(isPresented: Bool)
  case setMnemonic(mnemonic: String)
  case dismissBanner
  case viewTerms
}
