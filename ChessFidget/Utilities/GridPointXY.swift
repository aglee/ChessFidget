//
//  GridPointXY.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/7/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

// I put "XY" in the names "GridPointXY" and "VectorXY" to remind myself that:
// 1. the coordinates are in (x,y) order, and
// 2. the coordinates are 0-based.

/// A point in 2D with integer coordinates.
struct GridPointXY: Equatable, Hashable {
	let x: Int
	let y: Int

	init(_ x: Int, _ y: Int) {
		self.x = x
		self.y = y
	}

	// MARK: - Hashable protocol

	func hash(into hasher: inout Hasher) {
		hasher.combine(x)
		hasher.combine(y)
	}

	// MARK: - Equatable protocol

	public static func ==(lhs: GridPointXY, rhs: GridPointXY) -> Bool {
		return lhs.x == rhs.x && lhs.y == rhs.y
	}
}

/// A vector in 2D with integer coordinates.  Tuple notation is convenient.
typealias VectorXY = (dx: Int, dy: Int)  // dx, dy

func +(_ gridPoint: GridPointXY, _ vector: VectorXY) -> GridPointXY {
	return GridPointXY(gridPoint.x + vector.dx, gridPoint.y + vector.dy)
}

