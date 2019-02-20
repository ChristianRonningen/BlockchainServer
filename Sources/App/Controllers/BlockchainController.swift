//
//  BlockchainController.swift
//  App
//
//  Created by Christian Rönningen on 2019-02-15.
//

import Foundation
import Vapor

class BlockchainController {
    private (set) var blockchainService: BlockchainService
    var sockets: [WebSocket] = []
    init() {
        self.blockchainService = BlockchainService()
    }
    
    func getBlockchain(req: Request) -> Blockchain {
        return blockchainService.getBlockchain()
    }
    
    func getJob(req: Request) -> Block {
        return blockchainService.getNextJob()
    }
    
    func addTransaction(req: Request, transaction: Transaction) throws -> Transaction {
        return try blockchainService.addTransaction(transaction: transaction)
    }
    
    func verifyBlock(req: Request, block: Block) throws -> [String: String] {
        guard let miner = req.http.headers.firstValue(name: HTTPHeaderName("x_miner")) else {
            throw Abort(.badRequest, reason: "Missing miner")
        }
        
        let value = try blockchainService.verifyBlock(miner: miner, block: block)
        sockets.forEach({ $0.send("Update") })
        return value
    }
    
    func user(req: Request) -> Double {
        if let user = try? req.parameters.next(String.self) {
            return blockchainService.getUserAmount(address: user)
        } else {
            return 0
        }
    }
    
    func miner(socket: WebSocket, req: Request) {
        print("socket connected \(socket)")

        sockets.append(socket)

        socket.onError({ (socket, error) in
            print("error on socket")
        })
        socket.onCloseCode { (code) in
            print("close on socket")
        }
    }
}
