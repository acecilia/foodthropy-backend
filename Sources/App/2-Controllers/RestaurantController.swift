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
    private static let dataPairs:[(name: String, likes: Int)] = [
        ("Chinese", 5),
        ("Japanese", 9),
        ("Western", 20),
        ("Thai", 19),
        ("Handmade noodles", 45),
        ("Indian", 14),
        ("Spruce", 55),
        ("Pizza", 67),
        ("McDonalds", 0),
        ("Fish soup", 2),
        ("Soup spoon", 70),
        ("Economical rice", 157),
        ("Vegetarian", 97)
    ]
    
    static func dummyFill() throws {
        let locations = try Location.makeQuery().all()
        for location in locations {
            for pair in dataPairs {
                try Restaurant(name: pair.name, locationId: location.id!, likes: pair.likes).save()
            }
        }
    }
    
    static func delete() throws {
        try Restaurant.makeQuery().delete()
        // Reset id count
        try Restaurant.database?.raw("ALTER SEQUENCE restaurants_id_seq RESTART WITH 1")
    }
}
