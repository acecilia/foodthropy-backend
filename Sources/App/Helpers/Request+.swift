import Vapor
import HTTP

extension Request {
    /// Create a resource from the request data. Returns BadRequest error if invalid
    func resource<T:JSONConvertible>() throws -> T {
        guard let node = data[] else { throw Abort.badRequest }
        return try T(json: JSON(node))
    }
}
