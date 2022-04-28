//
//  LoginView.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

import SwiftUI
import ComposableArchitecture

struct LoginView: View {
  let store: Store<LoginState, LoginAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      NavigationView {
        ZStack {
          VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 12) {
              Image("logo")
                .resizable()
                .frame(width: 140, height: 140, alignment: .center)
              
              Text("podium")
                .textCase(.uppercase)
                .font(Font.custom("Carbon Bold", size: 54))
              
              VStack(alignment: .leading, spacing: 4) {
                Text("decentralized")
                  .textCase(.uppercase)
                  .font(Font.custom("Carbon Bold", size: 18))
                
                Text("open source")
                  .textCase(.uppercase)
                  .font(Font.custom("Carbon Bold", size: 18))
                
                Text("ad-free")
                  .textCase(.uppercase)
                  .font(Font.custom("Carbon Bold", size: 18))
                
                Text("free speech")
                  .textCase(.uppercase)
                  .font(Font.custom("Carbon Bold", size: 18))
                
                Text("web3 community network.")
                  .textCase(.uppercase)
                  .font(Font.custom("Carbon Bold", size: 18))
              }
            }
            .padding(.top, 60)
            
            Spacer()
            
            Button {
              
            } label: {
              HStack {
                Spacer()
                Text("How can I create a wallet ?")
                  .fontWeight(.medium)
                Spacer()
              }
            }
            
            Button {
              viewStore.send(.connect)
            } label: {
              HStack {
                Spacer()
                HStack {
                  Image("eth")
                    .resizable()
                    .frame(width: 22, height: 22, alignment: .center)
                    .foregroundColor(Color("ColorTextReverse"))
                  
                  Text("Connect Wallet")
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
            
            NavigationLink {
              RawLoginView(store: store)
            } label: {
              HStack {
                Spacer()
                HStack {
                  Text("Import wallet")
                    .textCase(.uppercase)
                    .foregroundColor(Color("ColorText"))
                    .font(Font.custom("Carbon Bold", size: 19))
                }
                Spacer()
              }
              .padding(.vertical, 22)
              .background(
                RoundedRectangle(cornerRadius: 9)
                  .stroke(Color("ColorText"), lineWidth: 2)
              )
            }
            
            Button {
              viewStore.send(.viewTerms)
            } label: {
              HStack {
                Spacer()
                Text("By connecting a wallet you agree to terms of service.")
                  .fontWeight(.medium)
                  .multilineTextAlignment(.leading)
                Spacer()
              }
            }
          }
          .padding(34)
        }
        .navigationBarHidden(true)
        .banner(data: viewStore.binding(
          get: \.bannerData,
          send: LoginAction.dismissBanner
        ))
      }
    }
  }
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView(store: Store(
      initialState: LoginState(),
      reducer: loginReducer,
      environment: AppEnvironment()
    ))
  }
}
