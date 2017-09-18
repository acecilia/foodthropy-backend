import Vapor
import HTTP
import Paginator
import FluentProvider
import Foundation

/// Here we have a controller that helps facilitate RESTful interactions with our object table
class DefaultController<T: Model & NodeRepresentable & JSONConvertible & Updateable & ResponseRepresentable>: ResourceRepresentable {
   
    required init() {}
    
    /// When users call 'GET' on the index path, it should return an index of all available posts
    func index(_ req: Request) throws -> ResponseRepresentable {
        if let page = req.query?["page"]?.int {
            let count = req.query?["count"]?.int ?? 10
            return try T.paginator(count, page: page, request: req)
        } else {
            return try T.all().makeJSON()
        }
    }

    /// When consumers call 'POST' on the index path with valid JSON, construct and save the post
    func store(_ req: Request) throws -> ResponseRepresentable {
        let resource: T = try req.resource()
        try resource.save()
        return resource
    }

    /// When the consumer calls 'GET' on a specific resource, we should show it
    func show(_ req: Request, resource: T) throws -> ResponseRepresentable {
        return resource
    }

    /// When the consumer calls 'DELETE' on a specific resource, we should remove that resource from the database
    func delete(_ req: Request, resource: T) throws -> ResponseRepresentable {
        try resource.delete()
        return Response(status: .ok)
    }

    /// When the consumer calls 'DELETE' on the entire table, we should remove the entire table
    func clear(_ req: Request) throws -> ResponseRepresentable {
        try T.makeQuery().delete()
        return Response(status: .ok)
    }

    /// When the user calls 'PATCH' on a specific resource, we should update that resource to the new values
    func update(_ req: Request, resource: T) throws -> ResponseRepresentable {
        // See `extension T: Updateable`
        try resource.update(for: req)

        // Save an return the updated resource.
        try resource.save()
        return resource
    }

    /// When a user calls 'PUT' on a specific resource, we should replace any values that do not exist in the request with null. This is equivalent to creating a new object with the same ID.
    func replace(_ req: Request, resource: T) throws -> ResponseRepresentable {
        
        // First attempt to create a new object from the supplied JSON.
        // If any required fields are missing, this request will be denied.
        let new: T = try req.resource()
        new.id = resource.id
        
        // This may be a performance overkill, we do not need to delete and create an object, but just update it's fields
        try resource.delete()

        // Update the resource with all of the properties from the new object
        try new.update(for: req)
        try new.save()

        // Return the updated resource
        return new
    }

    /// When making a controller, it is pretty flexible in that it only expects closures, this is useful for advanced scenarios, but most of the time, it should look almost identical to this implementation
    func makeResource() -> Resource<T> {
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

/// Since DefaultController doesn't require anything to be initialized we can conform it to EmptyInitializable. This will allow it to be passed by type.
extension DefaultController: EmptyInitializable { }
