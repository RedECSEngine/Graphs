import OrderedCollections

public struct OrderedDigraph<Node: Hashable> {
    private var successorLists: OrderedDictionary<Node, OrderedSet<Node>> = [:]
    private var predecessorLists: [Node: OrderedSet<Node>] = [:]

    public init() { }

    public var nodes: [Node] { Array(successorLists.keys) }
    public var count: Int { successorLists.count }
    public var isEmpty: Bool { successorLists.isEmpty }

    public func contains(_ node: Node) -> Bool {
        successorLists[node] != nil
    }

    public func successors(of node: Node) -> [Node] {
        Array(successorLists[node] ?? [])
    }

    public func predecessors(of node: Node) -> [Node] {
        Array(predecessorLists[node] ?? [])
    }

    public func outDegree(of node: Node) -> Int {
        successorLists[node]?.count ?? 0
    }

    public func inDegree(of node: Node) -> Int {
        predecessorLists[node]?.count ?? 0
    }

    public func hasEdge(from source: Node, to target: Node) -> Bool {
        successorLists[source]?.contains(target) ?? false
    }

    @discardableResult
    public mutating func insert(_ node: Node) -> Bool {
        guard successorLists[node] == nil else { return false }
        successorLists[node] = []
        predecessorLists[node] = []
        return true
    }

    @discardableResult
    public mutating func remove(_ node: Node) -> Bool {
        guard let successors = successorLists[node] else { return false }
        for successor in successors {
            predecessorLists[successor]?.remove(node)
        }
        for predecessor in predecessorLists[node] ?? [] {
            successorLists[predecessor]?.remove(node)
        }
        successorLists.removeValue(forKey: node)
        predecessorLists.removeValue(forKey: node)
        return true
    }

    @discardableResult
    public mutating func addEdge(from source: Node, to target: Node) -> Bool {
        insert(source)
        insert(target)
        guard successorLists[source]?.contains(target) == false else { return false }
        successorLists[source]?.append(target)
        predecessorLists[target]?.append(source)
        return true
    }

    @discardableResult
    public mutating func removeEdge(from source: Node, to target: Node) -> Bool {
        guard successorLists[source]?.contains(target) == true else { return false }
        successorLists[source]?.remove(target)
        predecessorLists[target]?.remove(source)
        return true
    }
}

extension OrderedDigraph: DirectedGraph { }

extension OrderedDigraph: Equatable {
    public static func == (lhs: OrderedDigraph, rhs: OrderedDigraph) -> Bool {
        lhs.successorLists == rhs.successorLists
    }
}

extension OrderedDigraph: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(successorLists)
    }
}

extension OrderedDigraph: Sendable where Node: Sendable { }

extension OrderedDigraph: Codable where Node: Codable {
    private enum CodingKeys: String, CodingKey {
        case successors
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(successorLists, forKey: .successors)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decoded = try container.decode(
            OrderedDictionary<Node, OrderedSet<Node>>.self,
            forKey: .successors
        )
        var graph = OrderedDigraph()
        for node in decoded.keys {
            graph.insert(node)
        }
        for (source, targets) in decoded {
            for target in targets {
                guard decoded[target] != nil else {
                    throw DecodingError.dataCorruptedError(
                        forKey: .successors,
                        in: container,
                        debugDescription: "edge target is not a node"
                    )
                }
                graph.addEdge(from: source, to: target)
            }
        }
        self = graph
    }
}
