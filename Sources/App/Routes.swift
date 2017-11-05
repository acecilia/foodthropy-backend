import Vapor

extension Droplet {
    func setupRoutes() throws {
        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        get("description") { req in return req.description }
        
        try RestaurantController.delete()
        try LocationController.delete()
        
        try LocationController.dummyFill()
        try RestaurantController.dummyFill()
        
        try resource("locations", LocationController.self)
        try resource("restaurants", RestaurantController.self)
    }
}
