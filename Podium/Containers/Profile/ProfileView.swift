//
//  ProfileView.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

import SwiftUI
import ComposableArchitecture

struct ProfileView: View {
  let store: Store<ProfileState, ProfileAction>
  
  @State private var tab = 0
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      NavigationView {
        ZStack {
          VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
              HStack {
                Button {
                  
                } label: {
                  if let avatar = viewStore.profile.avatar, avatar != "" {
                    AsyncImage(
                      url: URL(string: "https://ipfs.infura.io/ipfs/\(avatar)")!) {
                        ProgressView()
                      }
                      .scaledToFill()
                      .frame(width: 120, height: 120, alignment: .center)
                      .clipShape(Circle())
                  } else {
                    Image("dummy-avatar")
                      .resizable()
                      .scaledToFill()
                      .frame(width: 120, height: 120, alignment: .center)
                      .clipShape(Circle())
                  }
                }
                
                Spacer()
              }
              
              HStack {
                VStack(alignment: .leading, spacing: 4) {
                  if let username = viewStore.profile.username, username != "" {
                    Text("@\(username)")
                      .font(.largeTitle)
                      .fontWeight(.bold)
                      .truncationMode(.middle)
                  } else {
                    Text(viewStore.profile.userAddress)
                      .fontWeight(.semibold)
                      .lineLimit(1)
                  }
                  
                  if let bio = viewStore.profile.bio {
                    Text(bio)
                      .fontWeight(.medium)
                      .foregroundColor(.gray)
                  }
                }
                
                Spacer()
                
                if viewStore.isLocalProfile {
                  Button {
                    viewStore.send(.presentEdit(isPresented: true))
                  } label: {
                    HStack(spacing: 4) {
                      Image("edit")
                        .resizable()
                        .frame(width: 22, height: 22, alignment: .center)
                      
                      Text("Edit")
                        .textCase(.uppercase)
                        .font(Font.custom("Carbon Bold", size: 17))
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .foregroundColor(Color("ColorText"))
                    .background(
                      RoundedRectangle(cornerRadius: 9)
                        .stroke(Color("ColorText"), lineWidth: 1)
                    )
                  }
                }
              }
            }
            .sheet(
              isPresented: viewStore.binding(
                get: \.isEditPresented,
                send: ProfileAction.presentEdit(isPresented:)
              )
            ) {
              IfLetStore(
                self.store.scope(
                  state: \.editState,
                  action: ProfileAction.edit
                ),
                then: EditProfileView.init(store:)
              )
            }
            .padding(.horizontal, 24)
            
            VStack(spacing: 12) {
              Picker("Filter entries", selection: $tab) {
                Text("Latest").tag(0)
                Text("Media").tag(1)
                if viewStore.isLocalProfile {
                  Text("Pending").tag(2)
                }
              }
              .pickerStyle(.segmented)
              .padding(.horizontal)
              
              switch tab {
              case 0:
                ProfileLatestView(store: store)
                
              case 1:
                ProfileMediaView(store: store)
                
              case 2:
                ProfilePendingView(store: store)
                
              default:
                Text("No data")
              }
              
              Spacer()
            }
            .sheet(isPresented: viewStore.binding(
              get: \.isMediaPresented,
              send: ProfileAction.presentMedia(
                isPresented: !viewStore.isMediaPresented,
                photo: ""
              ))) {
                IfLetStore(
                  self.store.scope(
                    state: \.mediaState,
                    action: ProfileAction.media
                  ),
                  then: MediaView.init(store:)
                )
              }
          }
          .onAppear {
            viewStore.send(.fetchProfile)
            viewStore.send(.getStories)
          }
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
            
            ToolbarItem(placement: .navigationBarTrailing) {
              if viewStore.isLocalProfile {
                Button {
                  
                } label: {
                  Text("Sync")
                    .textCase(.uppercase)
                    .font(Font.custom("Carbon Bold", size: 17))
                }
              }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
              if viewStore.isLocalProfile {
                Button {
                  viewStore.send(.presentSettings(isPresented: true))
                } label: {
                  Image("settings")
                    .resizable()
                    .frame(width: 24, height: 24, alignment: .center)
                    .foregroundColor(Color("ColorText"))
                }
              }
            }
          }
          .banner(data: viewStore.binding(
            get: \.bannerData,
            send: ProfileAction.dismissBanner
          ))
          
          // Workaround for multiple NavigationLinks
          // https://github.com/pointfreeco/swift-composable-architecture/issues/393
          NavigationLink(destination: EmptyView()) {
            EmptyView()
          }
          
          WithViewStore(store.scope(state: \.isSettingsPresented)) { viewStore in
            NavigationLink(
              destination: IfLetStore(
                store.scope(
                  state: \.settingsState,
                  action: ProfileAction.settings
                ),
                then: { store in
                  SettingsView(store: store)
                }
              ),
              isActive: viewStore.binding(send: .presentSettings(isPresented: false)),
              label: EmptyView.init
            )
          }
        }
      }
    }
  }
}

struct ProfileView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
#if DEBUG
      ProfileView(store: Store(
        initialState: ProfileState(
          profile: Mocks().profile,
          stories: [
            Mocks().story
          ]
        ),
        reducer: profileReducer,
        environment: AppEnvironment()
      ))
      
      ProfileView(store: Store(
        initialState: ProfileState(
          profile: Mocks().profileEmpty
        ),
        reducer: profileReducer,
        environment: AppEnvironment()
      ))
#endif
    }
  }
}
