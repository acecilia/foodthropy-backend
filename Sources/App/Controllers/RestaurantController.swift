import FluentProvider

final class RestaurantController: DefaultController<Restaurant> {
    override func makeIndexQuery(fromParameters parameters: Node?) throws -> Query<Restaurant> {
        let query: Query<Restaurant>
        
        if let locationId: Int = try parameters?.get("locationid") {
            if let locationId = try Location.makeQuery().find(locationId) {
                query = try locationId.children(type: Restaurant.self)
                    .makeQuery()
            } else {
                throw Abort.badRequest
            }
        } else {
            query = try Restaurant.makeQuery()
        }
        
        return try query
            .filterName(fromParameters: parameters)
            .sort(Restaurant.likesKey, .descending)
            .sort(Restaurant.nameKey, .ascending)
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
