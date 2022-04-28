//
//  PodiumApp.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

import SwiftUI
import ComposableArchitecture

@main
struct PodiumApp: App {
  var body: some Scene {
    WindowGroup {
      AppView(
        store: Store(
          initialState: AppState(),
          reducer: appReducer,
          environment: AppEnvironment()
        ))
    }
  }
}
