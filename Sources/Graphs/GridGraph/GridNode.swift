public struct GridNode<N> {
    public var position: GridPosition
    public var data: N
}

extension GridNode: Equatable where N: Equatable {}
extension GridNode: Hashable where N: Hashable {}
extension GridNode: Codable where N: Codable {}

extension GridNode: CustomStringConvertible {
    public var description: String { "[\(position):\(data)]" }
}
