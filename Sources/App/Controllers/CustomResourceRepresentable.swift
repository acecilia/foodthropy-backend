import Vapor

protocol RouteMaker {
    func makeRoutes(path: String, drop: Droplet)
}
