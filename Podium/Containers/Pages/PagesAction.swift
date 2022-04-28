//
//  MainAction.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

enum PagesAction {
  // Actions
  case initialize
  case didGetStories(Result<[Story], Error>)
  
  // View Actions
  case list(ListAction)
  case profile(ProfileAction)
  case search(SearchAction)
}
