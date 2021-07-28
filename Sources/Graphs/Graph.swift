import Foundation

public protocol Graph {
    associatedtype Node: Hashable
    func nodes(adjacentTo node: Node) -> [Node]
    func canVisit(node: Node) -> Bool
}
