//
//  BlockchainService.swift
//  App
//
//  Created by Christian Rönningen on 2019-02-18.
//

import Foundation
import CommonCrypto

import Vapor

fileprivate struct Constants {
    static var MinerRewardAddress: String = "MRW"
}

enum BlockchainServiceError: AbortError, Debuggable {
    case insufficentFunds
    case badBlock
    
    var identifier: String {
        switch self {
        case .insufficentFunds:
            return "insufficentFunds"
        case .badBlock:
            return "badBlock"
        }
    }
    
    var status: HTTPResponseStatus {
        switch self {
        case .insufficentFunds:
            return .preconditionFailed
        case .badBlock:
            return .badRequest
        }
    }
    
    var reason: String {
        switch self {
        case .insufficentFunds:
            return "Insufficent funds"
        case .badBlock:
            return "Bad block"
        }
    }
}

class BlockchainService {
    
    private (set) var blockchain: Blockchain
    private var uncomfirmedTransactions: [Transaction] = []
    private var miners: [HTTPPeer] = []
    
    init() {
        let genesis = Block(transactions: [])
        self.blockchain = Blockchain(genesisBlock: genesis)
    }
    
    func getBlockchain() -> Blockchain {
        return blockchain
    }
    
    func getNextBlock(transactions: [Transaction]) -> Block {
        return Block(transactions: transactions)
    }
    
    func registerNodes(nodes: [BlockchainNode]) -> [BlockchainNode] {
        return blockchain.registerNodes(nodes: nodes)
    }
    
    func getNodes() -> [BlockchainNode] {
        return blockchain.nodes
    }
    
    func addTransaction(transaction: Transaction) throws -> Transaction {
        guard getUserAmount(address: transaction.from) >= transaction.amount || transaction.from == Constants.MinerRewardAddress else {
            throw BlockchainServiceError.insufficentFunds
        }
        
        uncomfirmedTransactions.append(transaction)
        return transaction
    }
    
    func getNextJob() -> Block {
        let block = Block(transactions: uncomfirmedTransactions)
        block.index = blockchain.blocks.count
        block.previousHash = blockchain.blocks.last!.hash
        return block
    }
    
    func sha256(string: String, index: Int, nounce: UInt) -> String {
        
        let str = "\(string)\(nounce)\(index)".cString(using: .utf8)
        let strLen = CUnsignedInt("\(string)\(nounce)\(index)".lengthOfBytes(using: .utf8))
        let digestLen = Int(CC_SHA256_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        defer {
            result.deallocate()
        }
        
        _ = CC_SHA256(str, strLen, result)
        
        var string = String()
        
        for i in 0..<Int(CC_SHA256_DIGEST_LENGTH) {
            string.append("\(result[i])")
        }
        
        return string
    }
    
    func verifyBlock(miner: String, block: Block) throws -> [String: String] {
        guard
            let index = block.index,
            let hash = block.hash,
            let previousHash = block.previousHash
        else {
            throw BlockchainServiceError.badBlock
        }
        
        guard
            hash.hasPrefix("000"),
            let json = try? JSONEncoder().encode(block.transactions),
            let stringToSha = String(data: json, encoding: .utf8),
            sha256(string: stringToSha, index: index, nounce: block.nounce!) == hash,
            previousHash == blockchain.blocks.last!.hash,
            blockchain.blocks.contains(block) == false,
            index <= blockchain.blocks.count
        else {
            throw BlockchainServiceError.badBlock
        }
        
        let uncomfirmedTransactions = self.uncomfirmedTransactions.filter({
            return !block.transactions.contains($0)
        })
        self.uncomfirmedTransactions = uncomfirmedTransactions
        
        let transaction = Transaction(from: Constants.MinerRewardAddress, to: miner, amount: 10)
        _ = try addTransaction(transaction: transaction)
        
        _ = blockchain.addBlock(block)
        
        return ["success": "block mined successfully"]
    }
    
    func resolve(completion: @escaping (Blockchain) -> ()) {
        let nodes = blockchain.nodes
        for node in nodes {
            let url = URL(string: "\(node.address)/api/blockchain")!
            let task = URLSession.shared.dataTask(with: url) { (data, _, _) in
                if let data = data {
                    let blockchain = try! JSONDecoder().decode(Blockchain.self, from: data)
                    if self.blockchain.blocks.count > blockchain.blocks.count {
                        completion(self.blockchain)
                    } else {
                        self.blockchain = blockchain
                        completion(blockchain)
                    }
                }
            }
            task.resume()
        }
    }
    
    func getUserAmount(address: String) -> Double {
        var value: Double = 0
        for transaction in uncomfirmedTransactions {
            // guard against double spend
            if transaction.from == address {
                value -= transaction.amount
            }
            // Don't count "possible" incoming funds just to be safe
//            if transaction.to == address {
//                value += transaction.amount
//            }
        }
        for block in blockchain.blocks {
            block.transactions.forEach { (trans) in
                if trans.from == address {
                    value -= trans.amount
                }
                if trans.to == address {
                    value += trans.amount
                }
            }
        }
        return value
    }
}