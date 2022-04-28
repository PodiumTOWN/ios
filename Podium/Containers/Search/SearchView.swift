//
//  SearchView.swift
//  ink
//
//  Created by Michael Jach on 14/04/2022.
//

import SwiftUI
import ComposableArchitecture

struct SearchView: View {
  let store: Store<SearchState, SearchAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      NavigationView {
        List(viewStore.filteredProfiles) { profile in
          VStack(alignment: .leading) {
            HStack(spacing: 8) {
              if let avatar = profile.avatar, avatar != "" {
                AsyncImage(
                  url: URL(string: "https://ipfs.infura.io/ipfs/\(avatar)")!) {
                    ProgressView()
                  }
                  .scaledToFill()
                  .frame(width: 44, height: 44, alignment: .center)
                  .clipShape(Circle())
              } else {
                Image("dummy-avatar")
                  .resizable()
                  .frame(width: 44, height: 44, alignment: .center)
                  .clipShape(Circle())
              }
              
              VStack(alignment: .leading) {
                Text(profile.username ?? profile.userAddress)
                  .fontWeight(.semibold)
                  .lineLimit(1)
                
                Text(profile.bio ?? "")
                  .fontWeight(.medium)
                  .foregroundColor(Color.gray)
              }
              
              Spacer()
              
              if viewStore.profile.following.contains(profile.userAddress) {
                Button {
                  viewStore.send(.unfollow(publicKey: profile.userAddress))
                } label: {
                  Text("Unfollow")
                    .foregroundColor(Color("ColorTextReverse"))
                    .fontWeight(.bold)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 18)
                .background(Color("AccentColor"))
                .clipShape(RoundedRectangle(cornerRadius: 13))
              } else {
                Button {
                  viewStore.send(.follow(publicKey: profile.userAddress))
                } label: {
                  Text("Follow")
                    .foregroundColor(Color("ColorTextReverse"))
                    .fontWeight(.bold)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 18)
                .background(Color("AccentColor"))
                .clipShape(RoundedRectangle(cornerRadius: 13))
              }
            }
          }
          .padding(.vertical, 12)
          .padding(.horizontal, 6)
        }
        .searchable(
          text: viewStore.binding(
            get: \.text,
            send: SearchAction.setText(text:)
          ),
          prompt: "Search usernames, public keys or tags"
        )
        .onChange(of: viewStore.text) { newQuery in
          viewStore.send(.search(text: newQuery))
        }
        .navigationTitle("Explore")
        
        .onAppear {
          viewStore.send(.fetchProfiles)
        }
      }
    }
  }
}

struct SearchView_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      #if DEBUG
      SearchView(store: Store(
        initialState: SearchState(
          profile: Mocks().profileEmpty,
          profiles: [
            Mocks().profileEmpty,
            Mocks().profileEmpty,
            Mocks().profileEmpty
          ]
        ),
        reducer: searchReducer,
        environment: AppEnvironment()
      ))
      #endif
    }
  }
}
