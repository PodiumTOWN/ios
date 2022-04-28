//
//  AppView.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {
  let store: Store<AppState, AppAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      ZStack {
        IfLetStore(
          self.store.scope(
            state: \.login,
            action: AppAction.login
          ),
          then: LoginView.init(store:)
        )
        
        IfLetStore(
          self.store.scope(
            state: \.pages,
            action: AppAction.pages
          ),
          then: PagesView.init(store:)
        )
      }
      .onAppear {
        viewStore.send(.getProfile)
      }
    }
  }
}

struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView(store: Store(
      initialState: AppState(),
      reducer: appReducer,
      environment: AppEnvironment()
    ))
  }
}
