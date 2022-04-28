//
//  MediaView.swift
//  ink
//
//  Created by Michael Jach on 15/04/2022.
//

import SwiftUI
import ComposableArchitecture

struct MediaView: View {
  let store: Store<MediaState, MediaAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      NavigationView {
        ZStack {
          Color.black
            .ignoresSafeArea()
          
          if let photo = viewStore.photo {
            AsyncImage(
              url: URL(string: "https://ipfs.infura.io/ipfs/\(photo)")!) {
                ProgressView()
              }
              .scaledToFit()
          }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Button {
              viewStore.send(.dismiss)
            } label: {
              Image("close")
                .resizable()
                .frame(width: 24, height: 24, alignment: .center)
                .foregroundColor(.white)
            }
          }
        }
      }
    }
  }
}

struct MediaView_Previews: PreviewProvider {
  static var previews: some View {
    MediaView(store: Store(
      initialState: MediaState(),
      reducer: mediaReducer,
      environment: AppEnvironment()
    ))
  }
}
