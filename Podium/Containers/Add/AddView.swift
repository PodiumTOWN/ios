//
//  AddView.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

import SwiftUI
import ComposableArchitecture

struct AddView: View {
  let store: Store<AddState, AddAction>
  
  @FocusState private var focusConfirm: Bool
  
  init(store: Store<AddState, AddAction>) {
    self.store = store
    UITextView.appearance().backgroundColor = .clear
  }
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      NavigationView {
        ZStack {
          Color("ColorBackground")
            .ignoresSafeArea()
          
          VStack(spacing: 0) {
            TextEditor(text: viewStore.binding(
              get: \.text,
              send: AddAction.setText
            ))
            .font(.largeTitle)
            .padding(.horizontal)
            .padding(.top, 12)
            .focused($focusConfirm)
            .onAppear {
              focusConfirm = true
            }
            
            HStack {
              Button {
                viewStore.send(.presentPicker(isPresented: true))
              } label: {
                VStack {
                  Image("addMedia")
                    .resizable()
                    .frame(width: 32, height: 32, alignment: .center)
                    .foregroundColor(Color("ColorText"))
                }
                .frame(width: 70, height: 70, alignment: .center)
                .background(Color("ColorBackgroundSecondary"))
                .clipShape(RoundedRectangle(cornerRadius: 13))
              }
              .disabled(viewStore.images.count >= 4)
              .opacity(viewStore.images.count >= 4 ? 0.4 : 1)
              
              HStack {
                if let images = viewStore.images, images.count > 0 {
                  ScrollView(.horizontal) {
                    HStack {
                      ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                          .resizable()
                          .scaledToFill()
                          .frame(width: 70, height: 70, alignment: .center)
                          .clipShape(RoundedRectangle(cornerRadius: 13))
                          .overlay(
                            ProgressView()
                              .opacity(viewStore.isLoading ? 1 : 0)
                              .frame(width: 70, height: 70, alignment: .center)
                              .background(Color("ColorBackground").opacity(viewStore.isLoading ? 0.4 : 0))
                              .clipShape(RoundedRectangle(cornerRadius: 13))
                          )
                      }
                    }
                  }
                }
              }
              
              Spacer()
              
              Button {
                viewStore.send(.send)
              } label: {
                HStack(spacing: 2) {
                  Image("eth")
                    .resizable()
                    .frame(width: 22, height: 22, alignment: .center)
                  
                  Text("Send")
                    .lineLimit(1)
                    .textCase(.uppercase)
                }
                .font(Font.custom("Carbon Bold", size: 19))
                .foregroundColor(Color("ColorTextReverse"))
                .padding(.vertical, 16)
              }
              .disabled(viewStore.isLoading)
              .opacity(viewStore.isLoading ? 0.4 : 1)
              .frame(width: 140)
              .background(
                LinearGradient(
                  colors:
                    [
                      Color("ColorGradient1"),
                      Color("ColorGradient2")
                    ],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                )
              )
              .clipShape(RoundedRectangle(cornerRadius: 15))
              .shadow(color: Color("ColorShadow"), radius: 34)
            }
            .padding()
            .sheet(isPresented: viewStore.binding(
              get: \.isPickerPresented,
              send: AddAction.presentPicker(isPresented:)
            )) {
              ImagePickerView(
                sourceType: .photoLibrary,
                selectedImage: viewStore.binding(
                  get: \.image,
                  send: AddAction.setImage(image:)
                )
              ) { image in
                print(image)
              }
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
                  .foregroundColor(Color("ColorText"))
              }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
              Text(String(220 - viewStore.text.count))
                .fontWeight(.medium)
                .foregroundColor(.gray)
                .padding()
            }
          }
        }
      }
    }
  }
}

struct AddView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      Text("")
        .sheet(isPresented: .constant(true)) {
          #if DEBUG
          AddView(store: Store(
            initialState: AddState(
              profile: Mocks().profile,
              text: "siema jak",
              images: [
                UIImage(named: "dummy-avatar")!
              ], isLoading: true
            ),
            reducer: addReducer,
            environment: AppEnvironment()
          ))
          .preferredColorScheme(.dark)
          #endif
        }
      #if DEBUG
      AddView(store: Store(
        initialState: AddState(
          profile: Mocks().profile,
          text: "siema jak",
          images: [
            //          UIImage(named: "dummy-avatar")!
          ]
        ),
        reducer: addReducer,
        environment: AppEnvironment()
      ))
      #endif
    }
  }
}
