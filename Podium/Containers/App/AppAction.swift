//
//  AppAction.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

import Foundation

enum AppAction {
  // Actions
  case getProfile
  case fetchProfile(publicKey: String, privateKey: Data?)
  case didFetchProfile(Result<Profile, Error>)
  
  // View Actions
  case login(LoginAction)
  case pages(PagesAction)
}
