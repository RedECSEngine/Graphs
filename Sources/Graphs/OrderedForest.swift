import OrderedCollections

public struct OrderedForest<Node: Hashable>: Equatable, Hashable {
    private var rootOrder: OrderedSet<Node> = []
    private var childLists: OrderedDictionary<Node, OrderedSet<Node>> = [:]
    private var parents: [Node: Node] = [:]

    public init() { }

    public var roots: [Node] { Array(rootOrder) }
    public var nodes: [Node] { depthFirstOrder(from: roots) }
    public var count: Int { childLists.count }
    public var isEmpty: Bool { childLists.isEmpty }

    public func contains(_ node: Node) -> Bool {
        childLists[node] != nil
    }

    public func parent(of node: Node) -> Node? {
        parents[node]
    }

    public func children(of node: Node) -> [Node] {
        Array(childLists[node] ?? [])
    }

    public func descendants(of node: Node) -> [Node] {
        guard contains(node) else { return [] }
        return depthFirstOrder(from: children(of: node))
    }

    public func isAncestor(_ ancestor: Node, of node: Node) -> Bool {
        var current = parents[node]
        while let candidate = current {
            if candidate == ancestor { return true }
            current = parents[candidate]
        }
        return false
    }

    @discardableResult
    public mutating func insert(_ node: Node, under parent: Node?) -> Bool {
        guard childLists[node] == nil else { return false }
        if let parent {
            guard childLists[parent] != nil else { return false }
            childLists[parent]?.append(node)
            parents[node] = parent
        } else {
            rootOrder.append(node)
        }
        childLists[node] = []
        return true
    }

    @discardableResult
    public mutating func move(_ node: Node, under parent: Node?) -> Bool {
        guard childLists[node] != nil else { return false }
        if let parent {
            guard childLists[parent] != nil,
                  parent != node,
                  !isAncestor(node, of: parent)
            else { return false }
        }

        if let currentParent = parents[node] {
            childLists[currentParent]?.remove(node)
        } else {
            rootOrder.remove(node)
        }

        if let parent {
            childLists[parent]?.append(node)
            parents[node] = parent
        } else {
            rootOrder.append(node)
            parents[node] = nil
        }
        return true
    }

    @discardableResult
    public mutating func remove(_ node: Node) -> [Node] {
        guard contains(node) else { return [] }
        let removed = [node] + descendants(of: node)
        if let parent = parents[node] {
            childLists[parent]?.remove(node)
        } else {
            rootOrder.remove(node)
        }
        for member in removed {
            childLists.removeValue(forKey: member)
            parents.removeValue(forKey: member)
        }
        return removed
    }
}

extension OrderedForest: DirectedGraph {
    public func successors(of node: Node) -> [Node] {
        children(of: node)
    }
}

extension OrderedForest: Sendable where Node: Sendable { }

extension OrderedForest: Codable where Node: Codable {
    private enum CodingKeys: String, CodingKey {
        case roots
        case children
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rootOrder, forKey: .roots)
        try container.encode(childLists, forKey: .children)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decodedRoots = try container.decode(OrderedSet<Node>.self, forKey: .roots)
        let decodedChildren = try container.decode(
            OrderedDictionary<Node, OrderedSet<Node>>.self,
            forKey: .children
        )

        func corrupt(_ message: String) -> DecodingError {
            DecodingError.dataCorruptedError(
                forKey: .children,
                in: container,
                debugDescription: message
            )
        }

        var decodedParents: [Node: Node] = [:]
        for (parent, children) in decodedChildren {
            for child in children {
                guard decodedChildren[child] != nil else {
                    throw corrupt("forest lists a child that is not a node")
                }
                guard decodedParents.updateValue(parent, forKey: child) == nil else {
                    throw corrupt("forest lists a node under more than one parent")
                }
            }
        }
        for root in decodedRoots {
            guard decodedChildren[root] != nil, decodedParents[root] == nil else {
                throw corrupt("forest roots must be parentless nodes")
            }
        }
        guard decodedRoots.count + decodedParents.count == decodedChildren.count else {
            throw corrupt("every node must be a root or have a parent")
        }

        var forest = OrderedForest()
        forest.rootOrder = decodedRoots
        forest.childLists = decodedChildren
        forest.parents = decodedParents
        guard forest.nodes.count == decodedChildren.count else {
            throw corrupt("forest contains nodes unreachable from its roots")
        }
        self = forest
    }
}
