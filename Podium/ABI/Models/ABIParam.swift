//
//  ABIParam.swift
//  ink
//
//  Created by Michael Jach on 06/04/2022.
//

struct ABIInputParam {
  let type: ABIParamType
  let value: Any
}

struct ABIParam {
  let name: String
  let type: ABIParamType
}
