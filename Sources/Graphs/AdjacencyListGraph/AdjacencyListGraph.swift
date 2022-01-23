import Foundation

public struct EdgeList<
    VertexType: Hashable & Codable,
    EdgeType: Hashable & Codable
>: Equatable & Hashable & Codable {
    public var vertex: Vertex<VertexType>
    public var edges: [Edge<VertexType, EdgeType>]?

    public init(vertex: Vertex<VertexType>) {
        self.vertex = vertex
    }

    public mutating func addEdge(_ edge: Edge<VertexType, EdgeType>) {
        edges?.append(edge)
    }
}

public struct AdjacencyListGraph<
    VertexType: Hashable & Codable,
    EdgeType: Hashable & Codable
>: Equatable & Hashable & Codable {
    public var adjacencyList: [EdgeList<VertexType, EdgeType>] = []

    public init() {}

    public init(fromGraph graph: AdjacencyListGraph<VertexType, EdgeType>) {
        for edge in graph.edges {
            let from = createVertex(edge.from.data)
            let to = createVertex(edge.to.data)

            addEdge(from, to: to, data: edge.data, withWeight: edge.weight)
        }
    }

    public var vertices: [Vertex<VertexType>] {
        var vertices = [Vertex<VertexType>]()
        for edgeList in adjacencyList {
            vertices.append(edgeList.vertex)
        }
        return vertices
    }

    public var edges: [Edge<VertexType, EdgeType>] {
        var allEdges = Set<Edge<VertexType, EdgeType>>()
        for edgeList in adjacencyList {
            guard let edges = edgeList.edges else {
                continue
            }

            for edge in edges {
                allEdges.insert(edge)
            }
        }
        return Array(allEdges)
    }

    public mutating func createVertex(_ data: VertexType) -> Vertex<VertexType> {
        // check if the vertex already exists
        let matchingVertices = vertices.filter { vertex in
            vertex.data == data
        }

        if matchingVertices.count > 0 {
            return matchingVertices[0]
        }

        // if the vertex doesn't exist, create a new one
        let vertex = Vertex(data: data, index: adjacencyList.count)
        adjacencyList.append(EdgeList(vertex: vertex))
        return vertex
    }

    public mutating func addEdge(_ from: Vertex<VertexType>, to: Vertex<VertexType>, data: EdgeType, withWeight weight: Double) {
        let edge = Edge(from: from, to: to, data: data, weight: weight)
        var edgeList = adjacencyList[from.index]
        if edgeList.edges != nil {
            edgeList.addEdge(edge)
        } else {
            edgeList.edges = [edge]
        }
        adjacencyList[from.index] = edgeList
    }

    public mutating func removeEdge(_ edge: Edge<VertexType, EdgeType>) {
        let list = adjacencyList[edge.from.index]
        if let edges = list.edges,
           let index = edges.firstIndex(of: edge)
        {
            adjacencyList[edge.from.index].edges?.remove(at: index)
        }
    }

    public mutating func removeAllEdges() {
        for i in 0 ..< adjacencyList.count {
            adjacencyList[i].edges?.removeAll()
        }
    }

    public func weightFrom(_ sourceVertex: Vertex<VertexType>, to destinationVertex: Vertex<VertexType>) -> Double {
        guard let edges = adjacencyList[sourceVertex.index].edges else {
            return -1
        }

        for edge: Edge<VertexType, EdgeType> in edges {
            if edge.to == destinationVertex {
                return edge.weight
            }
        }

        return -1
    }

    public func edgesFrom(_ sourceVertex: Vertex<VertexType>) -> [Edge<VertexType, EdgeType>] {
        adjacencyList[sourceVertex.index].edges ?? []
    }

    public var description: String {
        var rows = [String]()
        for edgeList in adjacencyList {
            guard let edges = edgeList.edges else {
                continue
            }

            var row = [String]()
            for edge in edges {
                let value = "\(edge.to.data): \(edge.weight))"
                row.append(value)
            }

            rows.append("\(edgeList.vertex.data) -> [\(row.joined(separator: ", "))]")
        }

        return rows.joined(separator: "\n")
    }
}

extension AdjacencyListGraph: Graph where VertexType: VisitableNode {
    public func nodes(adjacentTo node: Vertex<VertexType>) -> [Vertex<VertexType>] {
        Array(Set(edgesFrom(node).flatMap { edge in [edge.from, edge.to] }))
    }
    
    public func canVisit(node: Vertex<VertexType>) -> Bool {
        return node.data.canVisit()
    }
    
    public func pathfind(from: Vertex<VertexType>, to: Vertex<VertexType>) -> [Vertex<VertexType>] {
        AStarPathFinding.getPath(from: from, to: to, in: self, cost: {
            from, to in
            edgesFrom(from)
                .first(where: { $0.to == to })?
                .weight ?? .greatestFiniteMagnitude
        })
    }
}
