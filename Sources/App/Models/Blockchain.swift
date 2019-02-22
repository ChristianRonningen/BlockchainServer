//
//  Blockchain.swift
//  App
//
//  Created by Christian Rönningen on 2019-02-15.
//

import Foundation

import CryptoSwift
import Vapor

final class Blockchain: Content {
    var blocks: [Block] = []
    
    enum CodingKeys: String, CodingKey {
        case blocks = "blocks"
    }
    
    init(genesisBlock: Block) {
        genesisBlock.previousHash = "0000"
        genesisBlock.index = 0
        generateHash(for: genesisBlock)
        blocks.append(genesisBlock)
        print("Genesis created")
    }
    
    func generateHash(for block: Block) {
        let string = String(data: try! JSONEncoder().encode(block.transactions), encoding: .utf8)!
        var foundHash: String = ""
        var foundNounce: UInt32 = 0
        while foundHash.hasPrefix("0000") == false {
#if canImport(ObjectiveC)
            autoreleasepool {
                let nounce = UInt32.random(in: 0...UInt32.max)
                let hash = string.sha256(index: block.index!, nounce: nounce)
                foundHash = hash
                foundNounce = nounce
            }
#else
            let nounce = UInt32.random(in: 0...UInt32.max)
            let hash = string.sha256(index: block.index!, nounce: nounce)
            foundHash = hash
            foundNounce = nounce
#endif
        }
        block.hash = foundHash
        block.nounce = foundNounce
        
    }
    
    func addBlock(_ block: Block) -> Bool {
        guard block.hash != nil, block.index != nil, block.previousHash != nil else {
            return false
        }
        
        blocks.append(block)
        return true
    }
}

extension String {
    func sha256(index: Int, nounce: UInt32) -> String {
        return "\(self)\(nounce)\(index)".sha256()
    }
}
