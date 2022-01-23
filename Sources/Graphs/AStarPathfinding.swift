import Foundation

public protocol VisitableNode: Hashable {
    func canVisit() -> Bool
}

private func distanceCalculation<N>(from: GridNode<N>, to: GridNode<N>) -> Double {
    return sqrt(
        pow(Double(from.position.x - to.position.x), 2)  +
        pow(Double(from.position.y - to.position.y), 2)
    )
}

/// https://www.youtube.com/watch?v=eSOJ3ARN5FM
public struct AStarPathFinding {
    struct NodeTableData<G: Graph>: CustomStringConvertible {
        var distanceFromStart: Double
        var distanceToEnd: Double
        var totalCost: Double {
            distanceFromStart + distanceToEnd
        }
        var previousNode: G.Node?
        
        var description: String { "s:\(distanceFromStart),e:\(distanceToEnd),p:\(String(describing: previousNode))" }
    }
    
    public static func getPath<N>(
        from: GridGraph<N>.Node,
        to: GridGraph<N>.Node,
        in graph: GridGraph<N>,
        reverseLookupAlgorithmDirection: Bool = false
    ) -> [GridGraph<N>.Node] {
        return getPath(
            from: from,
            to: to,
            in: graph,
            cost: distanceCalculation,
            reverseLookupAlgorithmDirection: reverseLookupAlgorithmDirection
        )
    }
    
    public static func getPath<G: Graph>(
        from: G.Node,
        to: G.Node,
        in graph: G,
        cost: @escaping (G.Node, G.Node) -> Double,
        reverseLookupAlgorithmDirection: Bool = false
    ) -> [G.Node] {
        guard graph.canVisit(node: to) else {
            return []
        }
        
        if reverseLookupAlgorithmDirection {
            return Array(getPath(from: to, to: from, in: graph, cost: cost, reverseLookupAlgorithmDirection: false).reversed())
        }
        
        var tableData: [G.Node: NodeTableData<G>] = [:]
        var closedNodes: Set<G.Node> = []
        var openNodes: Set<G.Node> = []
        var currentNode: G.Node? = from
        let closestSort: (G.Node, G.Node) -> Bool = { (fromA, fromB) in
            let costA = tableData[fromA]?.totalCost ?? .greatestFiniteMagnitude
            let costB = tableData[fromB]?.totalCost ?? .greatestFiniteMagnitude
            return costA < costB
        }
        let insertOrUpdateNodeData: (G.Node, G.Node?) -> Void = { node, previous in
            openNodes.insert(node)
            let newData: NodeTableData<G> = .init(
                distanceFromStart: cost(node, from),
                distanceToEnd: cost(node, to),
                previousNode: previous
            )
            if let existingData = tableData[node],
                existingData.totalCost <= newData.totalCost {
                return
            }
            tableData[node] = newData
        }
        
        insertOrUpdateNodeData(from, nil)
        
        while let thisNode = currentNode, currentNode != to {
            let unvisitedAdjacentNodes = graph.nodes(adjacentTo: thisNode)
                .filter { !(closedNodes.contains($0) || openNodes.contains($0) || !graph.canVisit(node: $0)) }
            
            for node in unvisitedAdjacentNodes {
                insertOrUpdateNodeData(node, currentNode)
            }
            
            closedNodes.insert(thisNode)
            openNodes.remove(thisNode)
            currentNode = openNodes.sorted(by: closestSort).first
        }
        
        if let finalNode = currentNode {
            var path: [G.Node] = []
            var next: G.Node? = finalNode
            while let nextNode = next {
                path.append(nextNode)
                next = tableData[nextNode]?.previousNode
            }
            return Array(path.reversed())
        } else {
            return []
        }
    }
}
