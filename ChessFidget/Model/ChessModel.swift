//
//  ChessModel.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/24/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

import Foundation

enum PieceColor {
	case Black, White
}

enum PieceType {
	case Pawn, Knight, Bishop, Rook, Queen, King
}

struct Piece {
	let color: PieceColor
	let type: PieceType

	init(_ color: PieceColor, _ type: PieceType) {
		self.color = color
		self.type = type
	}
}

struct Square: Equatable, CustomStringConvertible {
	static let fileCharacters: [Character] = ["a", "b", "c", "d", "e", "f", "g", "h"]
	static let rankCharacters: [Character] = ["1", "2", "3", "4", "5", "6", "7", "8"]

	let x: Int
	let y: Int

	init(_ x: Int, _ y: Int) {
		self.x = x
		self.y = y
	}

	// MARK: CustomStringConvertible

	var description: String {
		get {
			return "\(Square.fileCharacters[x])\(Square.rankCharacters[y])"
		}
	}

	// MARK: Equatable

	public static func ==(lhs: Square, rhs: Square) -> Bool {
		return lhs.x == rhs.x && lhs.y == rhs.y
	}
}

struct Board {
	private var contents: [Piece?] = Array<Piece?>(repeating: nil, count: 64)

	init(newGame: Bool = true) {
		if newGame {
			placePiecesForNewGame()
		}
	}

	mutating func removeAllPieces() {
		contents = Array<Piece?>(repeating: nil, count: 64)
	}

	mutating func setUpNewGame() {
		removeAllPieces()
		placePiecesForNewGame()
	}

	// MARK: Subscripting

	subscript(_ x: Int, _ y: Int) -> Piece? {
		get {
			assert(indexIsValid(x, y), "Index out of range")
			return contents[(y * 8) + x]
		}
		set {
			assert(indexIsValid(x, y), "Index out of range")
			contents[(y * 8) + x] = newValue
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

	// MARK: Private functions

	private func indexIsValid(_ x: Int, _ y: Int) -> Bool {
		return x >= 0 && x < 8 && y >= 0 && y < 8
	}

	mutating func placePiecesForNewGame() {
		for x in 0...7 {
			self[x, 1] = Piece(.White, .Pawn)
			self[x, 6] = Piece(.Black, .Pawn)
		}

		let types: [PieceType] = [.Rook, .Knight, .Bishop, .Queen, .King, .Bishop, .Knight, .Rook]
		for (index, pieceType) in types.enumerated() {
			self[index, 0] = Piece(.White, pieceType)
			self[index, 7] = Piece(.Black, pieceType)
		}
	}
}

/**
Used (along with other logic) to determine whether a player can castle.

The default initializer uses the settings that are in effect at the beginning of a game.
*/
struct CastlingFlags {
	var queensRookDidMove: Bool = false
	var kingDidMove: Bool = false
	var kingsRookDidMove: Bool = false
}

/**
The default initializer uses the settings that are in effect at the beginning of a game.
*/
struct PositionMeta {
	var whoseTurn: PieceColor = .White
	var whiteCastlingFlags: CastlingFlags = CastlingFlags()
	var blackCastlingFlags: CastlingFlags = CastlingFlags()
	var squareWithTwoSquarePawn: Square? = nil
}

/**
Represents the state of a game, including all information needed to determine whether any proposed move is legal.

The default initializer uses the settings that are in effect at the beginning of a game.
*/
struct Position: CustomStringConvertible {
	//MARK: Properties

	let board: Board
	let meta: PositionMeta

	init() {
		board = Board()
		meta = PositionMeta()
	}

	init(board: Board, meta: PositionMeta) {
		self.board = board
		self.meta = meta
	}

	//MARK: Making moves

	func move(from: Square, to: Square) -> Position? {
		return nil
	}

	//MARK: CustomStringConvertible

	var description: String {
		get {
			return "hello"
		}
	}
}

enum MoveType {
	case Plain, PawnTwoSquares, CaptureEnPassant, KingSideCastle, QueenSideCastle
	case PawnPromotion(type: PieceType)
}

/**
Technically a misnomer.  This actually represents one "turn", or "ply".
*/
struct Move {
	let oldPosition: Position  // The position *preceding* the move.
	let fromSquare: Square
	let toSquare: Square
	var type: MoveType
}

class Game {
	var position: Position = Position()
	var moves: [Move] = []

	func playerHasPiece(at square: Square) -> Bool {
		if let piece = position.board[square] {
			return piece.color == position.meta.whoseTurn
		} else {
			return false
		}
	}

	// Returns nil if the move is illegal.
	func proposeMove(from fromSquare: Square, to toSquare: Square) -> Move? {
		return nil
	}

	func move(from fromSquare: Square, to toSquare: Square) -> Bool {
		return true
	}
}


