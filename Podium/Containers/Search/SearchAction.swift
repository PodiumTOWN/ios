//
//  SearchAction.swift
//  ink
//
//  Created by Michael Jach on 14/04/2022.
//

enum SearchAction {
  // Actions
  case setText(text: String)
  case search(text: String)
  case follow(publicKey: String)
  case unfollow(publicKey: String)
  case fetchProfiles
  case didFetchProfiles(Result<[Profile], AppError>)
  
  // View Actions
}
