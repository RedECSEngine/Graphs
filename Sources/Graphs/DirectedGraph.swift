public protocol DirectedGraph<Node> {
    associatedtype Node: Hashable

    var nodes: [Node] { get }
    func contains(_ node: Node) -> Bool
    func successors(of node: Node) -> [Node]
}

public extension DirectedGraph {
    func depthFirstOrder(from roots: [Node]) -> [Node] {
        var visited = Set<Node>()
        var result: [Node] = []
        var stack: [Node] = roots.reversed()
        while let node = stack.popLast() {
            guard visited.insert(node).inserted else { continue }
            result.append(node)
            stack.append(contentsOf: successors(of: node).reversed())
        }
        return result
    }
}
