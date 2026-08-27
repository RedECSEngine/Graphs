import XCTest
@testable import Graphs

final class OrderedDigraphTests: XCTestCase {
    func testNodesIterateInInsertionOrder() {
        var graph = OrderedDigraph<String>()
        graph.insert("c")
        graph.insert("a")
        graph.insert("b")
        XCTAssertEqual(graph.nodes, ["c", "a", "b"])
        XCTAssertEqual(graph.count, 3)
        XCTAssertTrue(graph.contains("a"))
        XCTAssertFalse(graph.contains("z"))
    }

    func testDuplicateInsertAndEdgeReturnFalse() {
        var graph = OrderedDigraph<String>()
        XCTAssertTrue(graph.insert("a"))
        XCTAssertFalse(graph.insert("a"))
        XCTAssertTrue(graph.addEdge(from: "a", to: "b"))
        XCTAssertFalse(graph.addEdge(from: "a", to: "b"))
        XCTAssertEqual(graph.outDegree(of: "a"), 1)
    }

    func testEdgesAutoInsertEndpointsAndKeepOrder() {
        var graph = OrderedDigraph<String>()
        graph.addEdge(from: "a", to: "c")
        graph.addEdge(from: "a", to: "b")
        graph.addEdge(from: "d", to: "a")
        XCTAssertEqual(graph.nodes, ["a", "c", "b", "d"])
        XCTAssertEqual(graph.successors(of: "a"), ["c", "b"])
        XCTAssertEqual(graph.predecessors(of: "a"), ["d"])
        XCTAssertTrue(graph.hasEdge(from: "a", to: "c"))
        XCTAssertFalse(graph.hasEdge(from: "c", to: "a"))
    }

    func testRemoveNodeClearsIncidentEdges() {
        var graph = OrderedDigraph<String>()
        graph.addEdge(from: "a", to: "b")
        graph.addEdge(from: "b", to: "c")
        graph.addEdge(from: "c", to: "a")

        XCTAssertTrue(graph.remove("b"))
        XCTAssertFalse(graph.contains("b"))
        XCTAssertEqual(graph.successors(of: "a"), [])
        XCTAssertEqual(graph.predecessors(of: "c"), [])
        XCTAssertEqual(graph.inDegree(of: "a"), 1)
        XCTAssertFalse(graph.remove("b"))
    }

    func testRemoveEdge() {
        var graph = OrderedDigraph<String>()
        graph.addEdge(from: "a", to: "b")
        XCTAssertTrue(graph.removeEdge(from: "a", to: "b"))
        XCTAssertFalse(graph.removeEdge(from: "a", to: "b"))
        XCTAssertEqual(graph.outDegree(of: "a"), 0)
        XCTAssertEqual(graph.inDegree(of: "b"), 0)
        XCTAssertTrue(graph.contains("b"))
    }

    func testSelfLoopAllowed() {
        var graph = OrderedDigraph<String>()
        XCTAssertTrue(graph.addEdge(from: "a", to: "a"))
        XCTAssertEqual(graph.successors(of: "a"), ["a"])
        XCTAssertEqual(graph.predecessors(of: "a"), ["a"])
        XCTAssertTrue(graph.remove("a"))
        XCTAssertTrue(graph.isEmpty)
    }

    func testDepthFirstOrderIsPreOrderAndCycleSafe() {
        var graph = OrderedDigraph<String>()
        graph.addEdge(from: "root", to: "a")
        graph.addEdge(from: "root", to: "b")
        graph.addEdge(from: "a", to: "a1")
        graph.addEdge(from: "a", to: "a2")
        graph.addEdge(from: "b", to: "root")
        XCTAssertEqual(graph.depthFirstOrder(from: ["root"]), ["root", "a", "a1", "a2", "b"])
    }

    func testCodableRoundTripEquals() throws {
        var graph = OrderedDigraph<String>()
        graph.addEdge(from: "a", to: "b")
        graph.addEdge(from: "a", to: "c")
        graph.addEdge(from: "c", to: "b")
        graph.insert("isolated")

        let data = try JSONEncoder().encode(graph)
        let decoded = try JSONDecoder().decode(OrderedDigraph<String>.self, from: data)
        XCTAssertEqual(decoded, graph)
        XCTAssertEqual(decoded.nodes, graph.nodes)
        XCTAssertEqual(decoded.successors(of: "a"), graph.successors(of: "a"))
    }

    func testEncodeTwiceIsByteIdentical() throws {
        var graph = OrderedDigraph<String>()
        graph.addEdge(from: "b", to: "a")
        graph.addEdge(from: "c", to: "a")
        graph.addEdge(from: "a", to: "d")

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let first = try encoder.encode(graph)
        let second = try encoder.encode(graph)
        XCTAssertEqual(first, second)

        let decoded = try JSONDecoder().decode(OrderedDigraph<String>.self, from: first)
        XCTAssertEqual(try encoder.encode(decoded), first)
    }

    func testDecodeRejectsUnknownEdgeTarget() throws {
        let json = #"{"successors":["a",["b"]]}"#
        XCTAssertThrowsError(
            try JSONDecoder().decode(OrderedDigraph<String>.self, from: Data(json.utf8))
        )
    }
}
