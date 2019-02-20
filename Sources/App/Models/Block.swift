//
//  Block.swift
//  App
//
//  Created by Christian Rönningen on 2019-02-15.
//

import Foundation

import Vapor

final class Block: Content, Equatable {
    let transactions: [Transaction]
    var index: Int? = nil
    var previousHash: String? = nil
    var hash: String? = nil
    var nounce: UInt? = nil
    
    init(transactions: [Transaction]) {
        self.transactions = transactions
    }
    
    static func ==(lhs: Block, rhs: Block) -> Bool {
        return lhs.transactions == rhs.transactions && lhs.index == rhs.index && lhs.previousHash == rhs.previousHash && lhs.hash == rhs.hash && lhs.nounce == rhs.nounce
    }
}

extension Block: CustomStringConvertible {
    var description: String {
        return "Transactions: [\(transactions)] hash: \(hash ?? "") previoushash: \(previousHash) index: \(index)"
    }
}
