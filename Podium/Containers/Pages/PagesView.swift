//
//  MainView.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

import SwiftUI
import ComposableArchitecture

struct PagesView: View {
  let store: Store<PagesState, PagesAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      TabView {
        IfLetStore(
          self.store.scope(
            state: \.listState,
            action: PagesAction.list
          ),
          then: ListView.init(store:)
        )
        .tabItem {
          Image("home")
            .resizable()
            .frame(width: 26, height: 26, alignment: .center)
        }
        
        IfLetStore(
          self.store.scope(
            state: \.searchState,
            action: PagesAction.search
          ),
          then: SearchView.init(store:)
        )
        .tabItem {
          Image("search")
            .resizable()
            .frame(width: 26, height: 26, alignment: .center)
        }
        
        Text("⌛ Coming soon...")
          .fontWeight(.medium)
          .foregroundColor(.gray)
          .tabItem {
            Image("messages")
              .resizable()
              .frame(width: 26, height: 26, alignment: .center)
          }
        
        IfLetStore(
          self.store.scope(
            state: \.profileState,
            action: PagesAction.profile
          ),
          then: ProfileView.init(store:)
        )
        .tabItem {
          Image("profile")
            .resizable()
            .frame(width: 26, height: 26, alignment: .center)
        }
      }
      .tabViewStyle(
        backgroundColor: Color("ColorBackground")
      )
      .onAppear {
        viewStore.send(.initialize)
      }
    }
  }
}

struct PagesView_Previews: PreviewProvider {
  static var previews: some View {
#if DEBUG
    PagesView(store: Store(
      initialState: PagesState(
        profile: Mocks().profile
      ),
      reducer: pagesReducer,
      environment: AppEnvironment()
    ))
#endif
  }
}
