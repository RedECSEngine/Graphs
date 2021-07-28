public struct GridGraph<N> {
    public private(set) var grid: [[GridNode<N>]]
    
    public var rows: Int { grid.count }
    public var cols: Int { grid[0].count }
    
    public var allowsTraversingDiagonals: Bool = true
    
    public init(rows: Int, cols: Int, initialValue: N) {
        guard rows > 0 && cols > 0 else {
            fatalError("invalid grid size")
        }
        
        grid = (0..<rows).map { row in
            (0..<cols).map { col in
                GridNode<N>(position: .init(x: col, y: row), data: initialValue)
            }
        }
    }
    
    public init(valueArray: [[N]]) {
        grid = (0..<valueArray.count).map { row in
            (0..<valueArray[row].count).map { col in
                GridNode<N>(position: .init(x: col, y: row), data: valueArray[row][col])
            }
        }
    }
    
    public func node(at position: GridPosition) -> GridNode<N> {
        return grid[position.y][position.x]
    }
    
    public mutating func updateNode(at position: GridPosition, value: N) {
        grid[position.y][position.x].data = value
    }
    
    public func nodesInArea(of node: GridNode<N>, radius: Int) -> [GridNode<N>] {
        (0...radius).flatMap { nodesInPerimeter(of: node, radius: $0) }
    }
    
    public func nodesInPerimeter(of node: GridNode<N>, radius: Int) -> [GridNode<N>] {
        guard radius > 0 else {
            return [node]
        }
        var nodes = [GridNode<N>]()
        for i in [-radius, radius] {
            // top && bottom row
            let y = node.position.y + i
            if y >= 0 && y < rows  {
                for j in (-radius...radius) {
                    let x = node.position.x + j
                    if x >= 0 && x < cols {
                        nodes.append(grid[y][x])
                    }
                }
            }
            // left and right column
            let x = node.position.x + i
            if x >= 0 && x < cols  {
                for j in (-(radius-1)...(radius-1)) {
                    let y = node.position.y + j
                    if y >= 0 && y < rows {
                        nodes.append(grid[y][x])
                    }
                }
            }
        }
        return nodes
    }
}

extension GridGraph: Equatable where N: Equatable { }
extension GridGraph: Codable where N: Codable { }

extension GridGraph: Graph where N: VisitableNode {
    public func nodes(adjacentTo node: GridNode<N>) -> [GridNode<N>] {
        if allowsTraversingDiagonals {
            return nodesInPerimeter(of: node, radius: 1)
//            if node.position.y + 1 < rows && node.position.x + 1 < cols {
//                nodes.append(grid[node.position.y + 1][node.position.x + 1])
//            }
//            if node.position.y - 1 >= rows && node.position.x - 1 >= 0 {
//                nodes.append(grid[node.position.y - 1][node.position.x - 1])
//            }
//            if node.position.y + 1 < rows && node.position.x - 1 >= 0 {
//                nodes.append(grid[node.position.y + 1][node.position.x - 1])
//            }
//            if node.position.y - 1 >= 0 && node.position.x + 1 < cols {
//                nodes.append(grid[node.position.y - 1][node.position.x + 1])
//            }
        } else {
            var nodes = [GridNode<N>]()
            if node.position.y + 1 < rows {
                nodes.append(grid[node.position.y + 1][node.position.x])
            }
            if node.position.y - 1 >= 0 {
                nodes.append(grid[node.position.y - 1][node.position.x])
            }
            if node.position.x + 1 < cols {
                nodes.append(grid[node.position.y][node.position.x + 1])
            }
            if node.position.x - 1 >= 0 {
                nodes.append(grid[node.position.y][node.position.x - 1])
            }
            return nodes
        }
    }
    
    public func canVisit(node: GridNode<N>) -> Bool {
        node.data.canVisit()
    }
}
