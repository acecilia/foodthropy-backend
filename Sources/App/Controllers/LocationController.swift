final class LocationController: DefaultController<Location> { }

extension LocationController: DummyFillable {
    static func dummyFill() throws {
        for number in 1...50 {
            try Location(name: "Food Court \(number)").save()
        }
    }
    
    static func delete() throws {
        try Location.makeQuery().delete()
        // Reset id count
        try Location.database?.raw("ALTER SEQUENCE locations_id_seq RESTART WITH 1")
    }
}
