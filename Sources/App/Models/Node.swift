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

extension BlockchainNode: Hashable, Equatable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.address)
    }
    
    static func ==(lhs: BlockchainNode, rhs: BlockchainNode) -> Bool {
        return lhs.address == rhs.address
    }
}
