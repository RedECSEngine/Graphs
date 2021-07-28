import XCTest
@testable import Graphs

extension Int: VisitableNode {
    public func canVisit() -> Bool { self != 0 }
}

final class GraphsTests: XCTestCase {
    
    var graph: GridGraph<Int>!
    
    override func setUp() {
        graph = .init(
            valueArray: [
                [1, 1, 1, 1],
                [1, 0, 0, 1],
                [0, 1, 0, 1],
                [0, 0, 1, 1]
            ]
        )
    }
    
    func testAreaQuerying() {
        let cornerNodes = graph.nodesInArea(of: graph.node(at: .init(x: 0, y: 0)), radius: 1)
        XCTAssertEqual(cornerNodes.count, 4)
        let positions = cornerNodes.map(\.position)
        XCTAssertEqual(positions.contains(.init(x: 0, y: 0)), true)
        XCTAssertEqual(positions.contains(.init(x: 0, y: 1)), true)
        XCTAssertEqual(positions.contains(.init(x: 1, y: 0)), true)
        XCTAssertEqual(positions.contains(.init(x: 1, y: 1)), true)
        
        XCTAssertEqual(graph.nodesInArea(of: graph.node(at: .init(x: 0, y: 0)), radius: 2).count, 9)
    }
    
    func testPerimeterQuerying() {
        let cornerNodes = graph.nodesInPerimeter(of: graph.node(at: .init(x: 0, y: 0)), radius: 1)
        XCTAssertEqual(cornerNodes.count, 3)
        let positions = cornerNodes.map(\.position)
        XCTAssertEqual(positions.contains(.init(x: 0, y: 1)), true)
        XCTAssertEqual(positions.contains(.init(x: 1, y: 0)), true)
        XCTAssertEqual(positions.contains(.init(x: 1, y: 1)), true)
        
        let centerNodes = graph.nodesInPerimeter(of: graph.node(at: .init(x: 2, y: 2)), radius: 1)
        XCTAssertEqual(centerNodes.count, 8)
        let positions2 = centerNodes.map(\.position)
        XCTAssertEqual(positions2.contains(.init(x: 1, y: 1)), true)
        XCTAssertEqual(positions2.contains(.init(x: 1, y: 2)), true)
        XCTAssertEqual(positions2.contains(.init(x: 2, y: 1)), true)
        XCTAssertEqual(positions2.contains(.init(x: 2, y: 3)), true)
        XCTAssertEqual(positions2.contains(.init(x: 3, y: 2)), true)
        XCTAssertEqual(positions2.contains(.init(x: 3, y: 1)), true)
        XCTAssertEqual(positions2.contains(.init(x: 1, y: 3)), true)
        XCTAssertEqual(positions2.contains(.init(x: 3, y: 3)), true)
        
        let cornerRadius2Nodes = graph.nodesInPerimeter(of: graph.node(at: .init(x: 0, y: 0)), radius: 2)
        XCTAssertEqual(cornerRadius2Nodes.count, 5)
        let radius2Positions = cornerRadius2Nodes.map(\.position)
        XCTAssertEqual(radius2Positions.contains(.init(x: 0, y: 2)), true)
        XCTAssertEqual(radius2Positions.contains(.init(x: 1, y: 2)), true)
        XCTAssertEqual(radius2Positions.contains(.init(x: 2, y: 2)), true)
        XCTAssertEqual(radius2Positions.contains(.init(x: 2, y: 1)), true)
        XCTAssertEqual(radius2Positions.contains(.init(x: 2, y: 0)), true)
        
        //radius 3 quick count check
        XCTAssertEqual(graph.nodesInPerimeter(of: graph.node(at: .init(x: 0, y: 0)), radius: 3).count, 7)
        
        //radius 4, outside of the graph area
        XCTAssertEqual(graph.nodesInPerimeter(of: graph.node(at: .init(x: 0, y: 0)), radius: 4).count, 0)
        
        //radius 0, just self
        let zeroRadiusNodes = graph.nodesInPerimeter(of: graph.node(at: .init(x: 0, y: 0)), radius: 0)
        XCTAssertEqual(zeroRadiusNodes.count, 1)
        XCTAssertEqual(zeroRadiusNodes.first?.position, .init(x: 0, y: 0))
    }
    
    func testGridGraphPathfindingShouldCalculateShortestPathWithoutDiagonals() {
        
        graph.allowsTraversingDiagonals = false
        
        let path = AStarPathFinding.getPath(
            from: graph.node(at: .init(x: 0, y: 0)),
            to: graph.node(at: .init(x: 3, y: 3)),
            in: graph,
            cost: { from, to in
            return sqrt(
                pow(Double(from.position.x - to.position.x), 2)  +
                pow(Double(from.position.y - to.position.y), 2)
            )
        })
        
        XCTAssert(!path.isEmpty)
        XCTAssertEqual(path.map { $0.position }, [
            .init(x: 0, y: 0),
            .init(x: 1, y: 0),
            .init(x: 2, y: 0),
            .init(x: 3, y: 0),
            .init(x: 3, y: 1),
            .init(x: 3, y: 2),
            .init(x: 3, y: 3)
        ])
    }
    
    func testGridGraphPathfindingShouldCalculateShortestPathIncludingDiagonals() {
        
        let path = AStarPathFinding.getPath(
            from: graph.node(at: .init(x: 0, y: 0)),
            to: graph.node(at: .init(x: 3, y: 3)),
            in: graph,
            cost: { from, to in
            return sqrt(
                pow(Double(from.position.x - to.position.x), 2)  +
                pow(Double(from.position.y - to.position.y), 2)
            )
        })
        
        XCTAssert(!path.isEmpty)
        XCTAssertEqual(path.map { $0.position }, [
            .init(x: 0, y: 0),
            .init(x: 0, y: 1),
            .init(x: 1, y: 2),
            .init(x: 2, y: 3),
            .init(x: 3, y: 3)
        ])
    }
}
