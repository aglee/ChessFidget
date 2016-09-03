//
//  MoveLookup.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/2/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

struct MoveLookup {

	private var lookup: [Int: [Int: Move]] = [:]

	mutating func add(move: Move) {
		let fromKey = lookupKeyForSquare(move.start)
		if lookup[fromKey] == nil {
			lookup[fromKey] = [:]
		}

		let toKey = lookupKeyForSquare(move.end)
		lookup[fromKey]![toKey] = move
	}

	func allMoves() -> [Move] {
		return Array(lookup.values.map({ return $0.values }).joined())
	}

	// All moves with the given starting square.
	func moves(from startSquare: Square) -> [Move] {
		if let lookupByends = lookup[lookupKeyForSquare(startSquare)] {
			return Array(lookupByends.values)
		} else {
			return []
		}
	}

	func move(from startSquare: Square, to endSquare: Square) -> Move? {
		return lookup[lookupKeyForSquare(startSquare)]?[lookupKeyForSquare(endSquare)]
	}

	// MARK: - Private methods

	private func lookupKeyForSquare(_ square: Square) -> Int {
		return 10*(square.x + 1) + (square.y + 1)
	}

	private func squareFromLookupKey(_ key: Int) -> Square {
		return Square(x: key/10 - 1, y: key%10 - 1)
	}
}

