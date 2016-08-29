//
//  Grid64.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/29/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

/**
An 8x8 grid of elements of type T.
*/
class Grid64<T> {
	var elements: [T]

	init(value: T) {
		elements = Array<T>(repeating: value, count: 64)
	}

	func fill(value: T) {
		for index in 0 ..< elements.count {
			elements[index] = value
		}
	}

	// MARK: - Subscripting

	subscript(_ x: Int, _ y: Int) -> T {
		get {
			assert(indexIsValid(x, y), "Index out of range")
			return elements[(y * 8) + x]
		}
		set {
			assert(indexIsValid(x, y), "Index out of range")
			elements[(y * 8) + x] = newValue
		}
	}

	subscript(_ square: Square) -> T {
		get {
			return self[square.x, square.y]
		}
		set {
			self[square.x, square.y] = newValue
		}
	}

	// MARK: - Private functions

	private func indexIsValid(_ x: Int, _ y: Int) -> Bool {
		return x >= 0 && x < 8 && y >= 0 && y < 8
	}
}

