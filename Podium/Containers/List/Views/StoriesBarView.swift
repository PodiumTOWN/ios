//
//  StoriesBarView.swift
//  Podium
//
//  Created by Michael Jach on 19/04/2022.
//

import SwiftUI
import ComposableArchitecture

struct StoriesBarView: View {
  let store: Store<ListState, ListAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      ScrollView(.horizontal) {
        HStack(spacing: 12) {
          if let avatar = viewStore.profile.avatar, avatar != "" {
            AsyncImage(
              url: URL(string: "https://ipfs.infura.io/ipfs/\(avatar)")!) {
                ProgressView()
              }
              .scaledToFill()
              .frame(width: 54, height: 54, alignment: .center)
              .clipShape(Circle())
              .padding(5)
            //            .overlay(
            //              Circle()
            //                .stroke(Color.accentColor, lineWidth: 3)
            //            )
          } else {
            Image("dummy-avatar")
              .resizable()
              .scaledToFill()
              .frame(width: 54, height: 54, alignment: .center)
              .clipShape(Circle())
              .padding(5)
            //            .overlay(
            //              Circle()
            //                .stroke(Color.accentColor, lineWidth: 3)
            //            )
          }
          
          Spacer()
        }
        .padding(12)
      }
      .sheet(isPresented: viewStore.binding(
        get: \.isStoryPresented,
        send: ListAction.presentStory(
          isPresented: !viewStore.isStoryPresented,
          story: ""
        ))
      ) {
        IfLetStore(
          self.store.scope(
            state: \.storyState,
            action: ListAction.story
          ),
          then: StoryView.init(store:)
        )
      }
    }
  }
}

struct StoriesBarView_Previews: PreviewProvider {
  static var previews: some View {
    #if DEBUG
    StoriesBarView(store: Store(
      initialState: ListState(
        profile: Mocks().profile
      ),
      reducer: listReducer,
      environment: AppEnvironment()
    ))
    #endif
  }
}
