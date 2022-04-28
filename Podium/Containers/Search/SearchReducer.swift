//
//  SearchReducer.swift
//  ink
//
//  Created by Michael Jach on 14/04/2022.
//

import ComposableArchitecture
import Combine

let searchReducer = Reducer<SearchState, SearchAction, AppEnvironment>.combine(
  Reducer { state, action, environment in
    switch action {
    case .setText(let text):
      state.text = text
      if text == "" {
        state.filteredProfiles = state.profiles
      } else {
        state.filteredProfiles = state.profiles.filter({ profile in
          if let username = profile.username {
            return username.contains(text.lowercased())
          } else {
            return false
          }
        })
      }
      return .none
      
    case .search(let text):
      return .none
      
    case .follow(let publicKey):
      return .none
      
    case .unfollow(let publicKey):
      return .none
      
    case .fetchProfiles:
      let publicKey = state.profile.userAddress
      let privateKey = state.profile.privateKey
      
      return Future<[Profile], AppError> { promise in
        environment.rpcApi.getProfiles(
          environment: environment,
          publicKey: publicKey,
          privateKey: privateKey) { profiles, error in
            if let profiles = profiles {
              promise(.success(profiles.filter({ $0.userAddress != publicKey })))
            } else if let error = error {
              promise(.failure(error))
            }
          }
      }
      .catchToEffect()
      .map(SearchAction.didFetchProfiles)
      
    case .didFetchProfiles(.success(let profiles)):
      state.profiles = profiles
      state.filteredProfiles = profiles
      return .none
      
    case .didFetchProfiles(.failure(let error)):
      return .none
    }
  }
)
