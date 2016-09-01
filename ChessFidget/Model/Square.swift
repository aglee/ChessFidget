//
//  Square.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/25/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

typealias Vector = (dx: Int, dy: Int)  // dx, dy

struct Square: Equatable, CustomStringConvertible {
	static let fileCharacters: [Character] = ["a", "b", "c", "d", "e", "f", "g", "h"]
	static let rankCharacters: [Character] = ["1", "2", "3", "4", "5", "6", "7", "8"]

	let x: Int
	let y: Int

	init(x: Int, y: Int) {
		self.x = x
		self.y = y
	}

	func plus(_ delta: Vector) -> Square {
		return Square(x: x + delta.dx, y: y + delta.dy)
	}

	// MARK: - CustomStringConvertible

	var description: String {
		get {
			if x == x % Square.fileCharacters.count
				&& y == y % Square.rankCharacters.count {
				return "\(Square.fileCharacters[x])\(Square.rankCharacters[y])"
			} else {
				return "Square(\(x),\(y))"
			}
		}
	}

	// MARK: - Equatable

	public static func ==(lhs: Square, rhs: Square) -> Bool {
		return lhs.x == rhs.x && lhs.y == rhs.y
	}
}



