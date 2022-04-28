//
//  MediaReducer.swift
//  ink
//
//  Created by Michael Jach on 15/04/2022.
//

import ComposableArchitecture
import Combine

let mediaReducer = Reducer<MediaState, MediaAction, AppEnvironment>.combine(
  Reducer { state, action, environment in
    switch action {
    case .dismiss:
      return .none
    }
  }
)

