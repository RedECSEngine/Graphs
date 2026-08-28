import XCTest
@testable import Graphs

final class OrderedForestTests: XCTestCase {
    private func makeForest() -> OrderedForest<String> {
        var forest = OrderedForest<String>()
        forest.insert("a", under: nil)
        forest.insert("b", under: nil)
        forest.insert("a1", under: "a")
        forest.insert("a2", under: "a")
        forest.insert("a1x", under: "a1")
        return forest
    }

    func testRootsAndChildrenKeepInsertionOrder() {
        let forest = makeForest()
        XCTAssertEqual(forest.roots, ["a", "b"])
        XCTAssertEqual(forest.children(of: "a"), ["a1", "a2"])
        XCTAssertEqual(forest.children(of: "b"), [])
        XCTAssertEqual(forest.parent(of: "a1x"), "a1")
        XCTAssertNil(forest.parent(of: "a"))
        XCTAssertEqual(forest.count, 5)
        XCTAssertTrue(forest.contains("a1x"))
        XCTAssertFalse(forest.contains("zz"))
    }

    func testNodesAndDescendantsAreDepthFirstPreOrder() {
        let forest = makeForest()
        XCTAssertEqual(forest.nodes, ["a", "a1", "a1x", "a2", "b"])
        XCTAssertEqual(forest.descendants(of: "a"), ["a1", "a1x", "a2"])
        XCTAssertEqual(forest.descendants(of: "b"), [])
        XCTAssertEqual(forest.descendants(of: "zz"), [])
    }

    func testInsertRejectsDuplicatesAndUnknownParents() {
        var forest = makeForest()
        XCTAssertFalse(forest.insert("a", under: nil))
        XCTAssertFalse(forest.insert("new", under: "zz"))
        XCTAssertEqual(forest, makeForest())
    }

    func testMoveKeepsSubtreeIntact() {
        var forest = makeForest()
        XCTAssertTrue(forest.move("a1", under: "b"))
        XCTAssertEqual(forest.children(of: "a"), ["a2"])
        XCTAssertEqual(forest.children(of: "b"), ["a1"])
        XCTAssertEqual(forest.children(of: "a1"), ["a1x"])
        XCTAssertEqual(forest.parent(of: "a1"), "b")
        XCTAssertEqual(forest.descendants(of: "b"), ["a1", "a1x"])
    }

    func testMoveToNilAppendsAtRootsEnd() {
        var forest = makeForest()
        XCTAssertTrue(forest.move("a1", under: nil))
        XCTAssertEqual(forest.roots, ["a", "b", "a1"])
        XCTAssertNil(forest.parent(of: "a1"))
        XCTAssertEqual(forest.children(of: "a1"), ["a1x"])
    }

    func testMoveRejectionsLeaveForestUnchanged() {
        var forest = makeForest()
        XCTAssertFalse(forest.move("zz", under: "a"))
        XCTAssertFalse(forest.move("a1", under: "zz"))
        XCTAssertFalse(forest.move("a1", under: "a1"))
        XCTAssertFalse(forest.move("a", under: "a1x"))
        XCTAssertEqual(forest, makeForest())
    }

    func testIsAncestor() {
        let forest = makeForest()
        XCTAssertTrue(forest.isAncestor("a", of: "a1x"))
        XCTAssertTrue(forest.isAncestor("a1", of: "a1x"))
        XCTAssertFalse(forest.isAncestor("a1x", of: "a"))
        XCTAssertFalse(forest.isAncestor("b", of: "a1"))
        XCTAssertFalse(forest.isAncestor("a", of: "a"))
    }

    func testRemoveReturnsPreOrderSubtree() {
        var forest = makeForest()
        XCTAssertEqual(forest.remove("a"), ["a", "a1", "a1x", "a2"])
        XCTAssertEqual(forest.roots, ["b"])
        XCTAssertEqual(forest.count, 1)
        XCTAssertFalse(forest.contains("a1x"))
        XCTAssertEqual(forest.remove("a"), [])
    }

    func testRemoveLeafDetachesFromParent() {
        var forest = makeForest()
        XCTAssertEqual(forest.remove("a1x"), ["a1x"])
        XCTAssertEqual(forest.children(of: "a1"), [])
        XCTAssertEqual(forest.count, 4)
    }

    func testDepthFirstOrderFromRootsMatchesNodes() {
        let forest = makeForest()
        XCTAssertEqual(forest.depthFirstOrder(from: forest.roots), forest.nodes)
    }

    func testCodableRoundTripEquals() throws {
        let forest = makeForest()
        let data = try JSONEncoder().encode(forest)
        let decoded = try JSONDecoder().decode(OrderedForest<String>.self, from: data)
        XCTAssertEqual(decoded, forest)
        XCTAssertEqual(decoded.nodes, forest.nodes)
        XCTAssertEqual(decoded.children(of: "a"), forest.children(of: "a"))
    }

    func testEncodeTwiceIsByteIdentical() throws {
        let forest = makeForest()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let first = try encoder.encode(forest)
        XCTAssertEqual(try encoder.encode(forest), first)
        let decoded = try JSONDecoder().decode(OrderedForest<String>.self, from: first)
        XCTAssertEqual(try encoder.encode(decoded), first)
    }

    func testDecodeRejectsCorruptPayloads() {
        let unknownChild = #"{"roots":["a"],"children":["a",["b"]]}"#
        XCTAssertThrowsError(
            try JSONDecoder().decode(OrderedForest<String>.self, from: Data(unknownChild.utf8))
        )
        let unreachable = #"{"roots":["a"],"children":["a",[],"b",[]]}"#
        XCTAssertThrowsError(
            try JSONDecoder().decode(OrderedForest<String>.self, from: Data(unreachable.utf8))
        )
        let duplicated = #"{"roots":["a","b"],"children":["a",["c"],"b",["c"],"c",[]]}"#
        XCTAssertThrowsError(
            try JSONDecoder().decode(OrderedForest<String>.self, from: Data(duplicated.utf8))
        )
    }
}
