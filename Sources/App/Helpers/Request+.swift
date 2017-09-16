import Vapor
import HTTP

extension Request {
    /// Create an obect from the JSON body return BadRequest error if invalid or no JSON
    func object<T:JSONConvertible>() throws -> T {
        guard let json = json else { throw Abort.badRequest }
        return try T(json: json)
    }
}
