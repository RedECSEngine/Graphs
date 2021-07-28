//
//  Edge.swift
//  Graph
//
//  Created by Andrew McKnight on 5/8/16.
//

import Foundation

public struct Edge<
    VertexType: Equatable & Hashable & Codable,
    EdgeType: Equatable & Hashable & Codable
>: Equatable & Hashable & Codable {
    public let from: Vertex<VertexType>
    public let to: Vertex<VertexType>

    public var data: EdgeType
    public let weight: Double
}

extension Edge: CustomStringConvertible {
    public var description: String {
        return "\(from.description) -(\(weight))-> \(to.description)"
    }
}
