//
//  AppEnvironment.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

import Foundation

struct AppEnvironment {
  let rpcUrl = "<RPC_URL>"
  let chainId = 137
  let ipfsUrl = "<IPFS_API_URL>"
  let userContractAddress = "<PODIUM_CONTRACT_ADDRESS>"
  let bridgeUrl = "<WALLET_CONNECT_BRIDGE_URL>"
  let etherscanUrl = "https://polygonscan.com"
  let walletConnect = WalletConnect()
  let rpcApi = RPCApi()
  let ipfsApi = IPFSApi()
  let storage = UserDefaults.standard
}
