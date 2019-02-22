import Vapor

private let blockchainController = BlockchainController()

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    let api = router.grouped("api")
    
    api.get("/blockchain", use: blockchainController.getBlockchain)
    api.post(Block.self, at: "/verifyBlock", use: blockchainController.verifyBlock)
    api.post(Transaction.self, at: "/transaction", use: blockchainController.addTransaction)
    api.get("/job", use: blockchainController.getJob)
    api.get("/user", String.parameter, use: blockchainController.user)
    api.get("/resolve", use: blockchainController.resolve)
    api.post(BlockchainNode.self, at: "/registerNode", use: blockchainController.registerNode)
}

public func socket(_ socket: NIOWebSocketServer) throws {
    socket.get(at: ["api","miner"], use: blockchainController.miner)
}
