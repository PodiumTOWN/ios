//
//  StoryView.swift
//  Podium
//
//  Created by Michael Jach on 19/04/2022.
//

import SwiftUI
import ComposableArchitecture

struct StoryView: View {
  let store: Store<StoryState, StoryAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      Text("Hello, World!")
    }
  }
}

struct StoryView_Previews: PreviewProvider {
  static var previews: some View {
    StoryView(store: Store(
      initialState: StoryState(),
      reducer: storyReducer,
      environment: AppEnvironment()
    ))
  }
}
