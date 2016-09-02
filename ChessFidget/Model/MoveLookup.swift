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
		let fromKey = lookupKeyForSquare(move.fromSquare)
		if lookup[fromKey] == nil {
			lookup[fromKey] = [:]
		}

		let toKey = lookupKeyForSquare(move.toSquare)
		lookup[fromKey]![toKey] = move
	}

	func allMoves() -> [Move] {
		return Array(lookup.values.map({ return $0.values }).joined())
	}

	// All moves with the given from-square.
	func moves(from fromSquare: Square) -> [Move] {
		if let lookupByToSquares = lookup[lookupKeyForSquare(fromSquare)] {
			return Array(lookupByToSquares.values)
		} else {
			return []
		}
	}

	func move(from fromSquare: Square, to toSquare: Square) -> Move? {
		return lookup[lookupKeyForSquare(fromSquare)]?[lookupKeyForSquare(toSquare)]
	}

	// MARK: - Private functions

	private func lookupKeyForSquare(_ square: Square) -> Int {
		return 10*(square.x + 1) + (square.y + 1)
	}

	private func squareFromLookupKey(_ key: Int) -> Square {
		return Square(x: key/10 - 1, y: key%10 - 1)
	}
}

