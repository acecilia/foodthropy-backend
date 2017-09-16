import Vapor
import FluentProvider
import HTTP

final class Restaurant: Model {
    let storage = Storage()
    
    static let idKey = "id"
    static let nameKey = "name"
    
    var name: String
    var restaurant: Parent<Restaurant, Location> { return parent(id: locationId) }

    var locationId: Identifier
    
    init(name: String, locationId: Identifier) {
        self.name = name
        self.locationId = locationId
    }
    
    init(row: Row) throws {
        name = try row.get(Restaurant.nameKey)
        locationId = try row.get(Location.foreignIdKey)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Restaurant.nameKey, name)
        try row.set(Location.foreignIdKey, locationId)
        return row
    }
}

extension Restaurant: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Restaurant.nameKey)
            builder.foreignId(for: Location.self)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Restaurant: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get(Restaurant.nameKey),
            locationId: json.get(Location.foreignIdKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Restaurant.idKey, id)
        try json.set(Restaurant.nameKey, name)
        try json.set(Location.foreignIdKey, locationId)
        return json
    }
}

extension Restaurant: ResponseRepresentable { }

extension Restaurant: Updateable {
    public static var updateableKeys: [UpdateableKey<Restaurant>] {
        return [
            UpdateableKey(Restaurant.nameKey, String.self) { $0.name = $1 },
            UpdateableKey(Location.foreignIdKey, Identifier.self) { $0.locationId = $1 }
        ]
    }
}
