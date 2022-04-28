//
//  WalletConnect.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

import Foundation
import WalletConnectSwift

class WalletConnect {
  var client: Client!
  var session: Session!
  var onConnect: ((_ session: Session) -> ())?
  var bridgeUrl: String?
  
  let sessionKey = "sessionKey"
  
  func setOnConnect(callback: @escaping (_ session: Session) -> ()) {
    self.onConnect = callback
  }
  
  func getUrl() -> String {
    let wcUrl =  WCURL(
      topic: UUID().uuidString,
      bridgeURL: URL(string: self.bridgeUrl!)!,
      key: try! randomKey()
    )
    
    return wcUrl.absoluteString
  }
  
  func connect(bridgeUrl: String, chainId: Int) -> String {
    self.bridgeUrl = bridgeUrl
    // gnosis wc bridge: https://safe-walletconnect.gnosis.io/
    // test bridge with latest protocol version: https://bridge.walletconnect.org
    let wcUrl =  WCURL(
      topic: UUID().uuidString,
      bridgeURL: URL(string: bridgeUrl)!,
      key: try! randomKey()
    )
    
    let clientMeta = Session.ClientMeta(
      name: "Podium",
      description: "web3 community network",
      icons: [URL(string: "https://avatars.githubusercontent.com/u/93730449?s=200&v=4")!],
      url: URL(string: "https://podium.town")!
    )
    let dAppInfo = Session.DAppInfo(
      peerId: UUID().uuidString,
      peerMeta: clientMeta,
      chainId: chainId
    )
    client = Client(delegate: self, dAppInfo: dAppInfo)
    
    print("WalletConnect URL: \(wcUrl.absoluteString)")
    
    try! client.connect(to: wcUrl)
    return wcUrl.absoluteString
  }
  
  func reconnectIfNeeded(bridgeUrl: String) {
    self.bridgeUrl = bridgeUrl
    if let oldSessionObject = UserDefaults.standard.object(forKey: sessionKey) as? Data,
       let session = try? JSONDecoder().decode(Session.self, from: oldSessionObject) {
      client = Client(delegate: self, dAppInfo: session.dAppInfo)
      try? client.reconnect(to: session)
    }
  }
  
  // https://developer.apple.com/documentation/security/1399291-secrandomcopybytes
  private func randomKey() throws -> String {
    var bytes = [Int8](repeating: 0, count: 32)
    let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
    if status == errSecSuccess {
      return Data(bytes: bytes, count: 32).toHexString()
    } else {
      // we don't care in the example app
      enum TestError: Error {
        case unknown
      }
      throw TestError.unknown
    }
  }
}

extension WalletConnect: ClientDelegate {
  func client(_ client: Client, didFailToConnect url: WCURL) {
    
  }
  
  func client(_ client: Client, didConnect url: WCURL) {
    // do nothing
  }
  
  func client(_ client: Client, didConnect session: Session) {
    self.session = session
    let sessionData = try! JSONEncoder().encode(session)
    UserDefaults.standard.set(sessionData, forKey: sessionKey)
    onConnect?(session)
  }
  
  func client(_ client: Client, didDisconnect session: Session) {
    UserDefaults.standard.removeObject(forKey: sessionKey)
  }
  
  func client(_ client: Client, didUpdate session: Session) {
    // do nothing
  }
}
