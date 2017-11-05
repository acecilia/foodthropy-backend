import FluentProvider

final class RestaurantController: DefaultController<Restaurant> {
    override func makeIndexQuery(fromParameters paramaters: Node?) throws -> Query<Restaurant> {
        var query = try super.makeIndexQuery(fromParameters: paramaters)
        
        if let locationId: Int = try paramaters?.get("locationid") {
            if let locationId = try Location.makeQuery().find(locationId) {
                query = try locationId.children(type: Restaurant.self).makeQuery()
            } else {
                throw BackendError.locationIdNotFound
            }
        }
        
        return query
    }
}

extension RestaurantController: DummyFillable {
    static func dummyFill() throws {
        let locations = try Location.makeQuery().limit(10).all()
        for location in locations {
            for number in 1...50 {
                try Restaurant(name: "Location: \(location.id!.int!), Chinese \(number)", locationId: location.id!).save()
            }
        }
    }
    
    static func delete() throws {
        try Restaurant.makeQuery().delete()
        // Reset id count
        try Restaurant.database?.raw("ALTER SEQUENCE restaurants_id_seq RESTART WITH 1")
    }
}

extension RestaurantController {
    enum BackendError: String, Error, Debuggable {
        case locationIdNotFound
        
        var reason: String {
            switch self {
            case .locationIdNotFound: return "The provided location id was not found on the database"
            }
        }
        
        var identifier: String {
            return self.rawValue
        }
        
        var possibleCauses: [String] {
            return []
        }
        
        var suggestedFixes: [String] {
            switch self {
            case .locationIdNotFound:
                return ["Provide an existing location id"]
            }
        }
    }
}



