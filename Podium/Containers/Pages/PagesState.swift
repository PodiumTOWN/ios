//
//  MainState.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

import Foundation

struct PagesState: Equatable {
  // Fields
  var profile: Profile
  var stories: [Story] = []
  
  // View States
  var listState: ListState?
  var profileState: ProfileState?
  var searchState: SearchState?
}
