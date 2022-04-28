//
//  SettingsReducer.swift
//  Podium
//
//  Created by Michael Jach on 19/04/2022.
//

import ComposableArchitecture
import Combine

let settingsReducer = Reducer<SettingsState, SettingsAction, AppEnvironment>.combine(
  Reducer { state, action, environment in
    switch action {
    case .disconnect:
      environment.storage.removeObject(forKey: "profile")
      environment.storage.removeObject(forKey: "stories")
      environment.storage.removeObject(forKey: "pending")
      return .none
      
    case .clearStorage:
      environment.storage.removeObject(forKey: "stories")
      environment.storage.removeObject(forKey: "pending")
      return .none
    }
  }
)
