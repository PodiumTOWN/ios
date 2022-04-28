//
//  RawLoginView.swift
//  Podium
//
//  Created by Michael Jach on 21/04/2022.
//

import SwiftUI
import ComposableArchitecture

struct RawLoginView: View {
  let store: Store<LoginState, LoginAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      ScrollView {
        VStack(alignment: .leading) {
          Text("Import")
            .textCase(.uppercase)
            .font(Font.custom("Carbon Bold", size: 46))
          
          Text("Paste your mnemonic passphrase below")
            .fontWeight(.medium)
            .foregroundColor(.gray)
          
          TextEditor(text: viewStore.binding(
            get: \.mnemonic,
            send: LoginAction.setMnemonic(mnemonic:)
          ))
          .autocapitalization(.allCharacters)
          .disableAutocorrection(true)
          .font(.title)
          .lineSpacing(2)
          .padding()
          .frame(minHeight: 240)
          .overlay(
            RoundedRectangle(cornerRadius: 13)
              .stroke(Color("ColorBackgroundTertiary"), lineWidth: 2)
          )
          
          Button {
            viewStore.send(.connectMnemonic)
          } label: {
            HStack {
              Spacer()
              HStack {
                Image("eth")
                  .resizable()
                  .frame(width: 22, height: 22, alignment: .center)
                  .foregroundColor(Color("ColorTextReverse"))
                
                Text("Import Wallet")
                  .textCase(.uppercase)
                  .foregroundColor(Color("ColorTextReverse"))
                  .font(Font.custom("Carbon Bold", size: 19))
              }
              Spacer()
            }
            .padding(.vertical, 22)
            .background(
              RoundedRectangle(cornerRadius: 9)
                .strokeBorder(Color("AccentColor"), lineWidth: 2)
                .background(RoundedRectangle(cornerRadius: 13).fill(Color("AccentColor")))
            )
          }
        }
        .padding()
      }
      .banner(data: viewStore.binding(
        get: \.bannerData,
        send: LoginAction.dismissBanner
      ))
    }
  }
}

struct RawLoginView_Previews: PreviewProvider {
  static var previews: some View {
    RawLoginView(store: Store(
      initialState: LoginState(),
      reducer: loginReducer,
      environment: AppEnvironment()
    ))
  }
}
