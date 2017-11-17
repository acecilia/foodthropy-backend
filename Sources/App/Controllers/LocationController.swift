import FluentProvider

final class LocationController: DefaultController<Location> {
    override func makeIndexQuery(fromParameters parameters: Node?) throws -> Query<Location> {
        return try Location.makeQuery().filterName(fromParameters: parameters)
    }
}

extension LocationController: DummyFillable {
    static func dummyFill() throws {
        for number in 1...11 {
            try Location(name: "Food court \(number)").save()
        }
        try Location(name: "Tamarin food court").save()
        try Location(name: "North Hill food court").save()
        try Location(name: "North Spine food court").save()
        try Location(name: "South Spine food court").save()
    }
    
    static func delete() throws {
        try Location.makeQuery().delete()
        // Reset id count
        try Location.database?.raw("ALTER SEQUENCE locations_id_seq RESTART WITH 1")
    }
}
