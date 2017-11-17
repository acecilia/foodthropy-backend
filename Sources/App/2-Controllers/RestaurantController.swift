import FluentProvider
import Random

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
    private static let types = [
        "Chinese",
        "Japanese",
        "Western",
        "Thai",
        "Handmade noodles",
        "Indian",
        "Spruce",
        "Pizza",
        "McDonalds",
        "Fish soup",
        "Soup spoon",
        "Economical rice",
        "Vegetarian"
    ]
    
    static func dummyFill() throws {
        let locations = try Location.makeQuery().all()
        for location in locations {
            
            for type in types {
                try Restaurant(name: type, locationId: location.id!, likes: Int.random(min: 0, max: 1500)).save()
            }
        }
    }
    
    static func delete() throws {
        try Restaurant.makeQuery().delete()
        // Reset id count
        try Restaurant.database?.raw("ALTER SEQUENCE restaurants_id_seq RESTART WITH 1")
    }
}
