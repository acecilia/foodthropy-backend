import Vapor
import HTTP
import Paginator
import FluentProvider
import Foundation
import Dispatch

/// Here we have a controller that helps facilitate RESTful interactions with our object table
class DefaultController<T: Model & NodeRepresentable & JSONConvertible & Updateable & ResponseRepresentable>: RouteMaker {
   
    required init() {}
    
    func makeIndexQuery(fromParameters parameters: Node?) throws -> Query<T> {
        return try T.makeQuery().sort(T.idKey, .ascending)
    }
    
    /// When users call 'GET' on the index path, it should return an index of all available posts
    func index(_ req: Request) throws -> ResponseRepresentable {
        var parameters = req.query
        let page: Int = try parameters?.pop("page") ?? 1
        let count: Int = try parameters?.pop("pagecount") ?? 20

        return try makeIndexQuery(fromParameters: parameters).paginator(count, page: page, request: req)
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

    class OngoingUpdates {
        var queue: DispatchQueue
        var count: Int
        
        init(_ queue: DispatchQueue) {
            self.queue = queue
            count = 0
        }
    }
    
    let ongoingUpdatesAccessQueue = DispatchQueue(label: "ongoingUpdatesAccessQueue")
    var ongoingUpdates:[Int: OngoingUpdates] = [:]
    
    /// When the user calls 'PATCH' on a specific resource, we should update that resource to the new values
    func update(_ req: Request) throws -> ResponseRepresentable {
        let id = try req.parameters.next(Int.self)
        
        // Safely check if there are ongoing updates. If there are, increment the queue. If there are not, start a new queue
        let idOngoingUpdates: OngoingUpdates = ongoingUpdatesAccessQueue.sync {
            let idOngoingUpdates: OngoingUpdates
            
            if let existingIdOngoingUpdates = ongoingUpdates[id] {
                idOngoingUpdates = existingIdOngoingUpdates
            } else {
                let newIdOngoingUpdates = OngoingUpdates(DispatchQueue(label: "ongoingUpdatesQueueForId_\(id)"))
                ongoingUpdates[id] = newIdOngoingUpdates
                idOngoingUpdates = newIdOngoingUpdates
            }
            
            idOngoingUpdates.count += 1
            return idOngoingUpdates
        }

        // Perform the update
        let result: Result<T>
        do {
            result = try idOngoingUpdates.queue.sync {
                guard let resource = try T.find(id) else {
                    throw Abort.badRequest
                }
                            
                try resource.update(for: req)
                try resource.save()
                return .success(resource)
            }
        } catch {
            result = .failure(error)
        }

        // If there are no operations pending in the queue, remove it from the main dictionary
        ongoingUpdatesAccessQueue.sync {
            idOngoingUpdates.count -= 1
            if idOngoingUpdates.count == 0 {
                ongoingUpdates.removeValue(forKey: id)
            } else {
                print("jeje: \(idOngoingUpdates.count)")
            }
        }
        
        // Return the result
        switch result {
        case .success(let resource): return resource
        case .failure(let error): throw error
        }
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

    func makeRoutes(path: String, drop: Droplet) {
        drop.get(path, handler: index)
        drop.patch(path, Int.parameter, handler: update)
    }
}

/// Since DefaultController doesn't require anything to be initialized we can conform it to EmptyInitializable. This will allow it to be passed by type.
extension DefaultController: EmptyInitializable { }
