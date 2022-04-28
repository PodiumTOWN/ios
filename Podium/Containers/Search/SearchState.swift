//
//  SearchState.swift
//  ink
//
//  Created by Michael Jach on 14/04/2022.
//

struct SearchState: Equatable {
  // Fields
  var profile: Profile
  var profiles: [Profile] = []
  var filteredProfiles: [Profile] = []
  var text: String = ""
  
  // View States
}
