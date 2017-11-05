import Node

extension Node {
    mutating func pop<T>(_ path: String) throws -> T {
        let value: T = try get(path)
        removeKey(path)
        return value
    }
}
