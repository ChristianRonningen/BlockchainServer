//
//  Blockchain.swift
//  App
//
//  Created by Christian Rönningen on 2019-02-15.
//

import Foundation
import CommonCrypto

import Vapor

final class Blockchain: Content {
    var blocks: [Block] = []
    private (set) var nodes: [BlockchainNode] = []
    
    enum CodingKeys: String, CodingKey {
        case blocks = "blocks"
    }
    
    init(genesisBlock: Block) {
        genesisBlock.previousHash = "0000"
        genesisBlock.index = 0
        generateHash(for: genesisBlock)
        blocks.append(genesisBlock)
    }
    
    func generateHash(for block: Block) {
        let string = String(data: try! JSONEncoder().encode(block.transactions), encoding: .utf8)!
        var foundHash: String = ""
        var foundNounce: UInt = 0
        while foundHash.hasPrefix("00") == false {
            let (hash, nounce) = string.sha256(index: block.index!, nounce: foundNounce + 1)
            print(hash)
            foundHash = hash
            foundNounce = nounce
        }
        block.hash = foundHash
        block.nounce = foundNounce
    }
    
    func registerNodes(nodes: [BlockchainNode]) -> [BlockchainNode] {
        self.nodes.append(contentsOf: nodes)
        return self.nodes
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
    func sha256(index: Int, nounce: UInt) -> (String, UInt) {
        
        let str = "\(self)\(nounce)\(index)".cString(using: .utf8)
        let strLen = CUnsignedInt("\(self)\(nounce)\(index)".lengthOfBytes(using: .utf8))
        let digestLen = Int(CC_SHA256_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        _ = CC_SHA256(str, strLen, result)
        
        var string = String()
        for i in 0..<Int(CC_SHA256_DIGEST_LENGTH) {
            string.append("\(result[i])")
        }
        //        print(string)
        result.deallocate()
        
        return (string, nounce)
    }
}
