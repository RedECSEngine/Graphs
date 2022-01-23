import Foundation

public struct Vertex<
    VertexType: Hashable & Codable
>: Equatable, Hashable, Codable {
    public var data: VertexType
    public let index: Int
}

extension Vertex: CustomStringConvertible {
    public var description: String {
        return "\(index): \(data)"
    }
}
