//
//  Board.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/29/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

struct Board {
	private var elements: [Piece?] = Array<Piece?>(repeating: nil, count: 64)

	func indexIsValid(_ x: Int, _ y: Int) -> Bool {
		return x >= 0 && x < 8 && y >= 0 && y < 8
	}

	func forAllSquares(_ action: (_ x: Int, _ y: Int) -> ()) {
		for x in 0...7 {
			for y in 0...7 {
				action(x, y)
			}
		}
	}
	
	func forAllSquares(_ action: (Square) -> ()) {
		for x in 0...7 {
			for y in 0...7 {
				action(Square(x: x, y: y))
			}
		}
	}

	// MARK: - Subscripting

	subscript(_ x: Int, _ y: Int) -> Piece? {
		get {
			assert(indexIsValid(x, y), "Index out of range")
			return elements[(y * 8) + x]
		}
		set {
			assert(indexIsValid(x, y), "Index out of range")
			elements[(y * 8) + x] = newValue
		}
	}

	subscript(_ square: Square) -> Piece? {
		get {
			return self[square.x, square.y]
		}
		set {
			self[square.x, square.y] = newValue
		}
	}
}

