import Vapor
import HTTP
import Paginator
import Foundation

/// Here we have a controller that helps facilitate RESTful interactions with our object table
final class LocationController: ResourceRepresentable {
    init() {
        do {
            try dummyFill()
        } catch {
            print(error)
            fatalError("There was a problem while filling the database with dummy data")
        }
    }
    
    func dummyFill() throws {
        if try Location.count() == 0 {
            let nf = NumberFormatter()
            nf.numberStyle = .spellOut
            nf.locale = Locale(identifier: "en_US")
            
            // Reset id count
            try Location.database?.raw("ALTER SEQUENCE locations_id_seq RESTART WITH 1")
            
            for number in 1...10 {
                if let name = nf.string(from: NSNumber(value: number)) {
                    try Location(name: name).save()
                }
            }
        }
    }
    
    /// When users call 'GET' on the index path, it should return an index of all available posts
    func index(_ req: Request) throws -> ResponseRepresentable {
        if let page = req.query?["page"]?.int {
            let count = req.query?["count"]?.int ?? 10
            return try Location.paginator(count, page: page, request: req)
        } else {
            return try Location.all().makeJSON()
        }
    }

    /// When consumers call 'POST' on the index path with valid JSON, construct and save the post
    func store(_ req: Request) throws -> ResponseRepresentable {
        let location: Location = try req.object()
        try location.save()
        return location
    }

    /// When the consumer calls 'GET' on a specific resource, we should show it
    func show(_ req: Request, location: Location) throws -> ResponseRepresentable {
        return location
    }

    /// When the consumer calls 'DELETE' on a specific resource, we should remove that resource from the database
    func delete(_ req: Request, location: Location) throws -> ResponseRepresentable {
        try location.delete()
        return Response(status: .ok)
    }

    /// When the consumer calls 'DELETE' on the entire table, we should remove the entire table
    func clear(_ req: Request) throws -> ResponseRepresentable {
        try Location.makeQuery().delete()
        return Response(status: .ok)
    }

    /// When the user calls 'PATCH' on a specific resource, we should update that resource to the new values
    func update(_ req: Request, location: Location) throws -> ResponseRepresentable {
        // See `extension Location: Updateable`
        try location.update(for: req)

        // Save an return the updated post.
        try location.save()
        return location
    }

    /// When a user calls 'PUT' on a specific resource, we should replace any values that do not exist in the request with null. This is equivalent to creating a new object with the same ID.
    func replace(_ req: Request, location: Location) throws -> ResponseRepresentable {
        // First attempt to create a new object from the supplied JSON.
        // If any required fields are missing, this request will be denied.
        let new: Location = try req.object()

        // Update the object with all of the properties from the new object
        location.name = new.name
        try location.save()

        // Return the updated object
        return location
    }

    /// When making a controller, it is pretty flexible in that it only expects closures, this is useful for advanced scenarios, but most of the time, it should look almost identical to this implementation
    func makeResource() -> Resource<Location> {
        return Resource(
            index: index,
            store: store,
            show: show,
            update: update,
            replace: replace,
            destroy: delete,
            clear: clear
        )
    }
}

/// Since LocationController doesn't require anything to be initialized we can conform it to EmptyInitializable. This will allow it to be passed by type.
extension LocationController: EmptyInitializable { }

extension LocationController {
    func cucu() {
        
    }
}
