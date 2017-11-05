import Vapor
import FluentProvider
import HTTP

final class Restaurant: Model {
    let storage = Storage()
    
    static let idKey = "id"
    static let nameKey = "name"
    static let ratingsKey = "ratings"
    static let averageRatingKey = "average_rating"
    
    var name: String
    var location: Location {
        return try! parent(id: locationId).get()!
    }
    fileprivate var locationId: Identifier
    private var ratings: [Int] {
        didSet { setAverageRating() }
    }
    var averageRating: Double?
    
    init(name: String, locationId: Identifier) {
        self.name = name
        self.locationId = locationId
        self.ratings = []
    }
    
    init(row: Row) throws {
        name = try row.get(Restaurant.nameKey)
        locationId = try row.get(Location.foreignIdKey)
        ratings = try row.get(Restaurant.ratingsKey)
        averageRating = try row.get(Restaurant.averageRatingKey)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Restaurant.nameKey, name)
        try row.set(Location.foreignIdKey, locationId)
        try row.set(Restaurant.ratingsKey, ratings)
        try row.set(Restaurant.averageRatingKey, averageRating)
        return row
    }
    
    private func setAverageRating() {
        averageRating = ratings.isEmpty ? 0 : Double(ratings.reduce(0, +)) / Double(ratings.count)
    }
}

extension Restaurant: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Restaurant.nameKey)
            builder.foreignId(for: Location.self)
            builder.custom(Restaurant.ratingsKey, type: "INTEGER[]")
            builder.double(Restaurant.averageRatingKey, optional: true)
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
        try json.set(Restaurant.averageRatingKey, averageRating)
        return json
    }
}

extension Restaurant: ResponseRepresentable { }

extension Restaurant: Updateable {
    public static var updateableKeys: [UpdateableKey<Restaurant>] {
        return [
            UpdateableKey(Restaurant.nameKey, String.self) { $0.name = $1 },
            UpdateableKey(Location.foreignIdKey, Identifier.self) { $0.locationId = $1 }
            // Fill more properties
        ]
    }
}

/// Needed for paginator to work
extension Restaurant: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        return try makeJSON().makeNode(in: context)
    }
}
