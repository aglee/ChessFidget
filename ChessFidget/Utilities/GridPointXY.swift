//
//  GridPointXY.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/7/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

/// I put "XY" in the names "GridPointXY" and "VectorXY" as a reminder that (1) the coordinates are in (x,y) order, and (2) the coordinates are 0-based.
struct GridPointXY: Equatable, Hashable {
	let x: Int
	let y: Int

	init(_ x: Int, _ y: Int) {
		self.x = x
		self.y = y
	}

	// MARK: - Hashable protocol

	var hashValue: Int {
		return x ^ y
	}

	// MARK: - Equatable protocol

	public static func ==(lhs: GridPointXY, rhs: GridPointXY) -> Bool {
		return lhs.x == rhs.x && lhs.y == rhs.y
	}
}

typealias VectorXY = (dx: Int, dy: Int)  // dx, dy

func +(_ gridPoint: GridPointXY, _ vector: VectorXY) -> GridPointXY {
	return GridPointXY(gridPoint.x + vector.dx, gridPoint.y + vector.dy)
}

