@_exported import Vapor

private(set) var drop: Droplet!

extension Droplet {
    public func setup() throws {
        drop = self
        try setupRoutes()
        // Do any additional droplet setup
    }
}
