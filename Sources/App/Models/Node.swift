//
//  Node.swift
//  App
//
//  Created by Christian Rönningen on 2019-02-18.
//

import Foundation

import Vapor

final class BlockchainNode: Content {
    var address: String
    
    init(address: String) {
        self.address = address
    }
}
