//
//  EditProfileView.swift
//  ink
//
//  Created by Michael Jach on 04/04/2022.
//

import SwiftUI
import ComposableArchitecture

struct EditProfileView: View {
  let store: Store<EditProfileState, EditProfileAction>
  
  init(store: Store<EditProfileState, EditProfileAction>) {
    self.store = store
    UITableView.appearance().backgroundColor = .clear
  }
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      NavigationView {
        ZStack {
          Color("ColorBackground")
            .ignoresSafeArea()
          
          List {
            Section(header: Text("Avatar")) {
              HStack {
                Spacer()
                Button {
                  viewStore.send(.presentImagePicker(isPresented: true))
                } label: {
                  if let image = viewStore.avatar {
                    Image(uiImage: image)
                      .resizable()
                      .scaledToFill()
                      .frame(width: 100, height: 100, alignment: .center)
                      .clipShape(Circle())
                      .overlay(
                        Image("edit")
                          .resizable()
                          .frame(width: 22, height: 22, alignment: .center)
                      )
                  } else if let image = viewStore.profile.avatar, image != "" {
                    AsyncImage(
                      url: URL(string: "https://ipfs.infura.io/ipfs/\(image)")!) {
                        ProgressView()
                      }
                      .scaledToFill()
                      .frame(width: 100, height: 100, alignment: .center)
                      .clipShape(Circle())
                      .overlay(
                        Image("edit")
                          .resizable()
                          .frame(width: 22, height: 22, alignment: .center)
                      )
                  } else {
                    Image("dummy-avatar")
                      .resizable()
                      .frame(width: 100, height: 100, alignment: .center)
                      .clipShape(Circle())
                      .overlay(
                        Image("edit")
                          .resizable()
                          .frame(width: 22, height: 22, alignment: .center)
                      )
                  }
                }
                .padding()
                
                Spacer()
              }
            }
            .listRowBackground(Color("ColorBackgroundSecondary"))
            
            Section(header: Text("General")) {
              HStack {
                Text("Username")
                  .fontWeight(.bold)
                
                TextField("Username", text: viewStore.binding(
                  get: \.username,
                  send: EditProfileAction.setUsername(username:)
                ))
                .autocapitalization(.none)
                .disableAutocorrection(true)
              }
              .padding(.vertical)
              
              HStack {
                Text("Bio")
                  .fontWeight(.bold)
                
                TextField("Bio", text: viewStore.binding(
                  get: \.bio,
                  send: EditProfileAction.setBio(bio:)
                ))
              }
              .padding(.vertical)
            }
            .listRowBackground(Color("ColorBackgroundSecondary"))
          }
          .background(Color("ColorBackground").ignoresSafeArea())
          .sheet(isPresented: viewStore.binding(
            get: \.isImagePickerPresented,
            send: EditProfileAction.presentImagePicker(isPresented:)
          )) {
            ImagePickerView(
              sourceType: .photoLibrary,
              selectedImage: viewStore.binding(
                get: \.avatar,
                send: EditProfileAction.setAvatar(image:)
              )
            ) { image in
              print(image)
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
                  .frame(width: 22, height: 22, alignment: .center)
                  .foregroundColor(Color("ColorText"))
              }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
              HStack {
                if viewStore.isLoading {
                  ProgressView()
                }
                
                Button {
                  viewStore.send(.save)
                } label: {
                  HStack(spacing: 2) {
                    Image("eth")
                      .resizable()
                      .frame(width: 22, height: 22, alignment: .center)
                    
                    Text("Save")
                      .textCase(.uppercase)
                      .font(Font.custom("Carbon Bold", size: 17))
                  }
                  .foregroundColor(Color("ColorText"))
                }
                .disabled(viewStore.isLoading)
                .opacity(viewStore.isLoading ? 0.4 : 1)
              }
            }
          }
        }
      }
    }
  }
}

struct EditProfileView_Previews: PreviewProvider {
  static var previews: some View {
#if DEBUG
    EditProfileView(store: Store(
      initialState: EditProfileState(
        profile: Mocks().profile
      ),
      reducer: editProfileReducer,
      environment: AppEnvironment()
    ))
    .preferredColorScheme(.dark)
#endif
  }
}
