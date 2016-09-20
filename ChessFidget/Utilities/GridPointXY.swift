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

	/// Returns nil if the string is not a valid two-character square notation (uppercase okay).
	init?(algebraic: String) {
		guard let xyPair = GridPointXY.xyFromString(algebraic: algebraic) else {
			return nil
		}

		x = xyPair.x
		y = xyPair.y
	}

	// MARK: - Hashable protocol

	var hashValue: Int {
		return x ^ y
	}

	// MARK: - Equatable protocol

	public static func ==(lhs: GridPointXY, rhs: GridPointXY) -> Bool {
		return lhs.x == rhs.x && lhs.y == rhs.y
	}

	// MARK: - Private methods

	private static func xyFromString(algebraic: String) -> (x: Int, y: Int)? {
		let unichars = Array(algebraic.lowercased().unicodeScalars)

		if unichars.count != 2 {
			print("ERROR: Cannot convert '\(algebraic)' - length must be 2.")
			return nil
		}

		let fileChar = unichars[0]
		let rankChar = unichars[1]

		if fileChar < "a" || fileChar > "h" {
			print("ERROR: Cannot convert '\(algebraic)' - file character must be in 'a'...'h'.")
			return nil
		}

		if rankChar < "1" || rankChar > "8" {
			print("ERROR: Cannot convert '\(algebraic)' - rank character must be in '1'...'8'.")
			return nil
		}

		return (x: Int(fileChar.value - UnicodeScalar("a").value),
		        y: Int(rankChar.value - UnicodeScalar("1").value))
	}
}

typealias VectorXY = (dx: Int, dy: Int)  // dx, dy

func +(_ gridPoint: GridPointXY, _ vector: VectorXY) -> GridPointXY {
	return GridPointXY(gridPoint.x + vector.dx, gridPoint.y + vector.dy)
}

