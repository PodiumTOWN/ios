//
//  LoginState.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

struct LoginState: Equatable {
  var isRawLoginPresented = false
  var mnemonic: String = ""
  var bannerData: BannerData?
}
