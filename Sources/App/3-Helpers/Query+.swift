import FluentProvider

extension Query {
    func filterName(fromParameters parameters: Node?) throws -> Query<E> {
        if let nameFilter: String = try parameters?.get("nameFilter") {
            // Case insensitive contains
            return try self.filter(raw: "name ILIKE '%\(nameFilter)%'")
        }
        return self
    }
}
