//
//  ProfileLatestView.swift
//  Podium
//
//  Created by Michael Jach on 19/04/2022.
//

import SwiftUI
import ComposableArchitecture

struct ProfileLatestView: View {
  let store: Store<ProfileState, ProfileAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      ScrollView {
        ForEach(viewStore.stories) { story in
          VStack {
            NavigationLink(
              isActive: viewStore.binding(
                get: \.isDetailPresented,
                send: ProfileAction.presentDetail(
                  isPresented: !viewStore.isDetailPresented,
                  story: story
                ))
            ) {
              IfLetStore(
                self.store.scope(
                  state: \.detailState,
                  action: ProfileAction.detail
                ),
                then: DetailView.init(store:)
              )
            } label: {
              PostTextView(
                story: story,
                onImageTap: { image in
                  viewStore.send(.presentMedia(isPresented: true, photo: image))
                },
                onProfileTap: { profile in
                  
                })
            }
            Divider()
          }
        }
      }
    }
  }
}
