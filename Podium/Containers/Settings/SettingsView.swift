//
//  SettingsView.swift
//  Podium
//
//  Created by Michael Jach on 19/04/2022.
//

import SwiftUI
import ComposableArchitecture

struct SettingsView: View {
  let store: Store<SettingsState, SettingsAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack {
        List {
          Section {
            Button {
              
            } label: {
              Text("Icon")
            }
            .listRowBackground(Color("ColorBackgroundSecondary"))
          } header: {
            Text("General")
          }
          
          Section {
            Button {
              
            } label: {
              Text("Podium DAO")
            }
            .listRowBackground(Color("ColorBackgroundSecondary"))
            
            Button {
              
            } label: {
              Text("Privacy policy")
            }
            .listRowBackground(Color("ColorBackgroundSecondary"))
            
            Button {
              
            } label: {
              Text("Terms of service")
            }
            .listRowBackground(Color("ColorBackgroundSecondary"))
          } header: {
            Text("Podium")
          }
          
          Section {
            Button {
              viewStore.send(.clearStorage)
            } label: {
              Text("Clear local storage")
            }
              .listRowBackground(Color("ColorBackgroundSecondary"))
            
            Button {
              viewStore.send(.disconnect)
            } label: {
              Text("Disconnect")
                .foregroundColor(.red)
            }
            .listRowBackground(Color("ColorBackgroundSecondary"))
          } header: {
            Text("Account")
          } footer: {
            HStack {
              Spacer()
              Image("logo")
                .resizable()
                .frame(width: 44, height: 44, alignment: .center)
              Spacer()
            }
          }
          
        }
      }
      .navigationTitle("Settings")
    }
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView(store: Store(
      initialState: SettingsState(),
      reducer: settingsReducer,
      environment: AppEnvironment()
    ))
  }
}
