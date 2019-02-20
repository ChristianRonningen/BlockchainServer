//
//  Transaction.swift
//  App
//
//  Created by Christian Rönningen on 2019-02-15.
//

import Foundation

import Vapor

final class Transaction: Content, Equatable {
    let from: String
    let to: String
    let amount: Double
    
    init(from: String, to: String, amount: Double) {
        self.from = from
        self.to = to
        self.amount = amount
    }
    
    public static func ==(lhs: Transaction, rhs: Transaction) -> Bool {
        return lhs.from == rhs.from && lhs.to == rhs.to && lhs.amount == rhs.amount
    }
}

extension Transaction: CustomStringConvertible {
    var description: String {
        return "from: \(from) to: \(to) amount: \(amount)"
    }
}
