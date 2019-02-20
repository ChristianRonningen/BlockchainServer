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

/*
import CommonCrypto

struct Transaction: Codable {
    let from: String
    let to: String
    let amount: Double
}

extension Transaction: CustomStringConvertible {
    var description: String {
        return "from: \(from) to: \(to) amount: \(amount)"
    }
}

class Block {
    let transactions: [Transaction]
    let index: Int
    let previousHash: String
    var hash: String? = nil
    var nounce: UInt? = nil
    
    init(transactions: [Transaction], index: Int, previousHash: String) {
        self.transactions = transactions
        self.index = index
        self.previousHash = previousHash
    }
}

extension Block: CustomStringConvertible {
    var description: String {
        return "Transactions: [\(transactions)] hash: \(hash ?? "") previoushash: \(previousHash) index: \(index)"
    }
}

class Blockchain {
    private var blockchain: [Block] = []
    init(genesis: Block) {
        generateHash(for: genesis)
        blockchain.append(genesis)
    }
    
    func addTransactions(_ transactions: [Transaction]) {
        let previousBlock = blockchain.last!
        let block = Block(transactions: transactions, index: previousBlock.index + 1, previousHash: previousBlock.hash!)
        generateHash(for: block)
        blockchain.append(block)
        
        if validateChain() == false {
            print("Chain is invalid")
            abort()
        } else {
            print("Chain checked")
        }
    }
    
    func validateChain() -> Bool {
        var valid = true
        for (index, block) in blockchain.enumerated() {
            if index == 0 {
                if block.previousHash != "0000" {
                    valid = false
                    break
                }
            } else {
                if block.previousHash != blockchain[index - 1].hash! {
                    valid = false
                    break
                }
            }
            
        }
        return valid
    }
    
    func generateHash(for block: Block) {
        let string = String(data: try! JSONEncoder().encode(block.transactions), encoding: .utf8)!
        var foundHash: String = ""
        var foundNounce: UInt = 0
        while foundHash.hasPrefix("00") == false {
            let (hash, nounce) = string.sha256(index: block.index, nounce: foundNounce + 1)
            foundHash = hash
            foundNounce = nounce
        }
        block.hash = foundHash
        block.nounce = foundNounce
    }
}

extension Blockchain: CustomStringConvertible {
    var description: String {
        var string = String()
        for i in blockchain {
            string.append("\(i)\n")
        }
        return string
    }
}

extension String {
    func sha256(index: Int, nounce: UInt) -> (String, UInt) {
        
        let str = "\(self)\(nounce)\(index)".cString(using: .utf8)
        let strLen = CUnsignedInt("\(self)\(nounce)\(index)".lengthOfBytes(using: .utf8))
        let digestLen = Int(CC_SHA256_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        _ = CC_SHA256(str, strLen, result)
        
        var string = String()
        for i in 0..<Int(CC_SHA1_DIGEST_LENGTH) {
            string.append("\(result[i])")
        }
        //        print(string)
        result.deallocate()
        
        return (string, nounce)
    }
}
*/
