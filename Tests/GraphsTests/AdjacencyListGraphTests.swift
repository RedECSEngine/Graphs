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
}
