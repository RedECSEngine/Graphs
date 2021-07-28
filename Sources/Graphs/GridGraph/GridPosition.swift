public struct GridPosition: Hashable, Codable {
    public var x: Int
    public var y: Int
    
    public init(
        x: Int,
        y: Int
    ) {
        self.x = x
        self.y = y
    }
}

extension GridPosition: CustomStringConvertible {
    public var description: String { "(\(x),\(y))" }
}
