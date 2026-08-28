import XCTest
@testable import Graphs

final class AdjacencyListGraphTests: XCTestCase {
    func testEdgesAreInsertionOrderedAndDeduplicated() {
        var graph = AdjacencyListGraph<String, String>()
        let a = graph.createVertex("a")
        let b = graph.createVertex("b")
        let c = graph.createVertex("c")

        graph.addEdge(a, to: b, data: "ab", withWeight: 1)
        graph.addEdge(a, to: c, data: "ac", withWeight: 1)
        graph.addEdge(b, to: c, data: "bc", withWeight: 1)
        graph.addEdge(a, to: b, data: "ab", withWeight: 1)

        let expected: [(String, String)] = [("a", "b"), ("a", "c"), ("b", "c")]
        let edges = graph.edges
        XCTAssertEqual(edges.count, expected.count)
        for (edge, pair) in zip(edges, expected) {
            XCTAssertEqual(edge.from.data, pair.0)
            XCTAssertEqual(edge.to.data, pair.1)
        }
        XCTAssertEqual(graph.edges, edges)
    }

    func testMinimumSpanningTreePicksCheapestAcyclicEdges() {
        var graph = AdjacencyListGraph<String, String>()
        let a = graph.createVertex("a")
        let b = graph.createVertex("b")
        let c = graph.createVertex("c")
        let d = graph.createVertex("d")

        graph.addEdge(a, to: b, data: "ab", withWeight: 1)
        graph.addEdge(a, to: c, data: "ac", withWeight: 4)
        graph.addEdge(b, to: d, data: "bd", withWeight: 2)
        graph.addEdge(c, to: d, data: "cd", withWeight: 5)
        graph.addEdge(b, to: c, data: "bc", withWeight: 3)

        let result = minimumSpanningTreeKruskal(graph: graph)

        XCTAssertEqual(result.cost, 6)
        let picked = result.tree.edges.map { ($0.from.data, $0.to.data, $0.weight) }
        XCTAssertEqual(picked.count, 3)
        XCTAssertTrue(picked[0] == ("a", "b", 1))
        XCTAssertTrue(picked[1] == ("b", "d", 2))
        XCTAssertTrue(picked[2] == ("b", "c", 3))
        XCTAssertEqual(result.tree.vertices, graph.vertices)
    }
}
