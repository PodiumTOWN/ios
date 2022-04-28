//
//  MainView.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

import SwiftUI
import ComposableArchitecture

struct ListView: View {
  let store: Store<ListState, ListAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      NavigationView {
        ZStack {
          VStack(spacing: 0) {
            List {
              ForEach(viewStore.stories) { story in
                VStack(spacing: 0) {
                  PostTextView(
                    story: story,
                    onImageTap: { image in
                      viewStore.send(.presentMedia(isPresented: true, photo: image))
                    },
                    onProfileTap: { profile in
                      viewStore.send(.presentProfile(isPresented: true, profile: profile))
                    }
                  )
                  .onTapGesture {
                    viewStore.send(.presentDetail(
                      isPresented: !viewStore.isDetailPresented,
                      story: story
                    ))
                  }
                  
                  Divider()
                    .padding(0)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
              }
            }
            .onAppear {
              UITableView.appearance().separatorStyle = .none
            }
            .refreshable {
              await viewStore.send(.getStories, while: \.isLoadingRefreshable)
            }
            .listStyle(PlainListStyle())
            .sheet(isPresented: viewStore.binding(
              get: \.isPhotoPresented,
              send: ListAction.presentMedia(
                isPresented: !viewStore.isPhotoPresented,
                photo: ""
              ))) {
                IfLetStore(
                  self.store.scope(
                    state: \.mediaState,
                    action: ListAction.media
                  ),
                  then: MediaView.init(store:)
                )
              }
            
            Divider()
              .padding(0)
            
            HStack(spacing: 0) {
              StoriesBarView(store: store)
              
              Button {
                viewStore.send(.presentAdd(isPresented: true))
              } label: {
                Image("add")
                  .resizable()
                  .frame(width: 28, height: 28, alignment: .center)
                  .padding(.horizontal, 26)
                  .foregroundColor(Color("AccentColor"))
              }
            }
          }
          .navigationBarHidden(true)
          .navigationBarTitleDisplayMode(.inline)
          .sheet(isPresented: viewStore.binding(
            get: \.isAddPresented,
            send: ListAction.presentAdd(isPresented:))
          ) {
            IfLetStore(
              self.store.scope(
                state: \.addState,
                action: ListAction.add
              ),
              then: AddView.init(store:)
            )
          }
          .banner(data: viewStore.binding(
            get: \.bannerData,
            send: ListAction.dismissBanner
          ))
          
          // Workaround for multiple NavigationLinks
          // https://github.com/pointfreeco/swift-composable-architecture/issues/393
          NavigationLink(destination: EmptyView()) {
            EmptyView()
          }
          
          WithViewStore(store.scope(state: \.isDetailPresented)) { viewStore in
            NavigationLink(
              destination: IfLetStore(
                store.scope(
                  state: \.detailState,
                  action: ListAction.detail
                ),
                then: { store in
                  DetailView(store: store)
                }
              ),
              isActive: viewStore.binding(send: .presentDetail(
                isPresented: false,
                story: Story(index: 0, owner: "")
              )),
              label: EmptyView.init
            )
          }
        }
        .overlay(alignment: .top, content: {
          Color.clear
            .background(Color("ColorBackground"))
            .edgesIgnoringSafeArea(.top)
            .frame(height: 0)
        })
        .sheet(isPresented: viewStore.binding(
          get: \.isProfilePresented,
          send: ListAction.presentProfile(
            isPresented: !viewStore.isProfilePresented,
            profile: nil
          ))) {
            IfLetStore(
              self.store.scope(
                state: \.profileState,
                action: ListAction.profile
              ),
              then: ProfileView.init(store:)
            )
          }
      }
    }
  }
}

struct ListView_Previews: PreviewProvider {
  static var previews: some View {
    #if DEBUG
    ListView(store: Store(
      initialState: ListState(
        profile: Mocks().profile,
        stories: [
          Mocks().story,
          Mocks().story,
          Mocks().story,
          Mocks().story
        ]
      ),
      reducer: listReducer,
      environment: AppEnvironment()
    ))
    #endif
  }
}
