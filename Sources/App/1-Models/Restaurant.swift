import FluentProvider

final class Restaurant: Model {
    let storage = Storage()
    
    static let nameKey = "name"
    static let likesKey = "likes"
    
    let name: String
    var location: Location {
        return try! parent(id: locationId).get()!
    }
    private var locationId: Identifier
    private(set) var likes: Int
    
    init(name: String, locationId: Identifier, likes: Int = 0) {
        self.name = name
        self.locationId = locationId
        self.likes = likes
    }
    
    init(row: Row) throws {
        name = try row.get(Restaurant.nameKey)
        locationId = try row.get(Location.foreignIdKey)
        likes = try row.get(Restaurant.likesKey)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Restaurant.nameKey, name)
        try row.set(Location.foreignIdKey, locationId)
        try row.set(Restaurant.likesKey, likes)
        return row
    }
}

extension Restaurant: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Restaurant.nameKey)
            builder.foreignId(for: Location.self)
            builder.int(Restaurant.likesKey, optional: true)
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
            locationId: json.get(Location.foreignIdKey),
            likes: json.get(Restaurant.likesKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Restaurant.idKey, id)
        try json.set(Restaurant.nameKey, name)
        try json.set(Location.foreignIdKey, locationId)
        try json.set(Restaurant.likesKey, likes)
        return json
    }
}

extension Restaurant: ResponseRepresentable { }

extension Restaurant: Updateable {
    public static var updateableKeys: [UpdateableKey<Restaurant>] {
        return [
            UpdateableKey("like", Bool.self) {
                if $1 {
                    $0.likes += 1
                } else {
                    $0.likes -= 1
                }
            }
        ]
    }
}

extension Restaurant: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        return try makeJSON().makeNode(in: context)
    }
}
