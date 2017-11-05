import FluentProvider

final class RestaurantController: DefaultController<Restaurant> {
    override func makeIndexQuery(fromParameters paramaters: Node?) throws -> Query<Restaurant> {
        var query = try super.makeIndexQuery(fromParameters: paramaters)
        if let locationId: Int = try paramaters?.get("locationid") {
            if let childrenQuery = try Location.makeQuery().find(locationId)?.children(type: Restaurant.self).makeQuery() {
                query = childrenQuery
            }
            
        }
        return query
    }
}

extension RestaurantController: DummyFillable {
    static func dummyFill() throws {
        try Restaurant.makeQuery().delete()
        // Reset id count
        try Restaurant.database?.raw("ALTER SEQUENCE restaurants_id_seq RESTART WITH 1")
        
        let locations = try Location.makeQuery().limit(10).all()
        for location in locations {
            for number in 1...200 {
                try Restaurant(name: "Chinese \(number)", locationId: location.id!).save()
            }
        }
    }
}


