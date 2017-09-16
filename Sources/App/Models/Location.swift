import Vapor
import FluentProvider
import HTTP

final class Location: Model {
    let storage = Storage()
    
    // MARK: Properties and database keys
    
    /// The column keys
    static let idKey = "id"
    static let nameKey = "name"
    
    /// The column values
    var name: String
    
    /// Creates a new object
    init(name: String) {
        self.name = name
    }
    
    // MARK: Fluent Serialization
    
    /// Initializes the object from the database row
    init(row: Row) throws {
        name = try row.get(Location.nameKey)
    }
    
    // Serializes the object to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Location.nameKey, name)
        return row
    }
}

// MARK: Fluent Preparation

extension Location: Preparation {
    /// Prepares a table/collection in the database for storing objects
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Location.nameKey)
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new object
//     - Fetching an object
//
extension Location: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get(Location.nameKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Location.idKey, id)
        try json.set(Location.nameKey, name)
        return json
    }
}

// MARK: HTTP

// This allows object models to be returned directly in route closures
extension Location: ResponseRepresentable { }

// MARK: Update

// This allows the object model to be updated dynamically by the request
extension Location: Updateable {
    // Updateable keys are called when `object.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<Location>] {
        return [
            // If the request contains a String at the key the setter callback will be called
            UpdateableKey(Location.nameKey, String.self) { $0.name = $1 }
        ]
    }
}

/// Needed for paginator to work
extension Location: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        return try makeJSON().makeNode(in: context)
    }
}
