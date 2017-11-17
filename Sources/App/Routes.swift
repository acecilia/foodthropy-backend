import Vapor

extension Droplet {
    func setupRoutes() throws {
        get("reset") { req in
            try RestaurantController.delete()
            try LocationController.delete()
            
            try LocationController.dummyFill()
            try RestaurantController.dummyFill()
            
            return Response(status: .ok)
        }

        LocationController().makeRoutes(path: "locations", drop: self)
        RestaurantController().makeRoutes(path: "restaurants", drop: self)
    }
}
