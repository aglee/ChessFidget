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

	func opponent() -> PieceColor {
		return self == .White ? .Black : .White
	}
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

struct Square: CustomStringConvertible {
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
}

struct Board<T> {
	private var contents: [T]

	init(value: T) {
		contents = Array<T>(repeating: value, count: 64)
	}

	// MARK: Subscripting

	subscript(_ x: Int, _ y: Int) -> T {
		get {
			assert(indexIsValid(x, y), "Index out of range")
			return contents[(y * 8) + x]
		}
		set {
			assert(indexIsValid(x, y), "Index out of range")
			contents[(y * 8) + x] = newValue
		}
	}

	// MARK: Private

	private func indexIsValid(_ x: Int, _ y: Int) -> Bool {
		return x >= 0 && x < 8 && y >= 0 && y < 8
	}
}

typealias BoardMask = Board<Bool>
typealias PieceLayout = Board<Piece?>

extension String {
	init(_ board: BoardMask) {
		self.init()

		var text = ""

		for y in stride(from:7, through:0, by: -1) {
			for x in 0...7 {
				text.append(board[x, y] ? "X" : "•")
			}
			if y > 0 {
				text.append("\n")
			}
		}

		self.append(text)
	}

	init(_ board: PieceLayout) {
		self.init()

		var text = ""

		for y in stride(from:7, through:0, by: -1) {
			for x in 0...7 {
				text.append(String.pieceCharacter(board[x, y]))
			}
			if y > 0 {
				text.append("\n")
			}
		}

		self.append(text)
	}

	// MARK: Private functions

	private static func pieceCharacter(_ piece: Piece?) -> Character {
		if let piece = piece {
			switch piece.color {
			case .White:
				switch piece.type {
				case .Pawn: return "♙"
				case .Knight: return "♘"
				case .Bishop: return "♗"
				case .Rook: return "♖"
				case .King: return "♔"
				case .Queen: return "♕"
				}
			case .Black:
				switch piece.type {
				case .Pawn: return "♟"
				case .Knight: return "♞"
				case .Bishop: return "♝"
				case .Rook: return "♜"
				case .King: return "♚"
				case .Queen: return "♛"
				}
			}
		} else {
			return "•"
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
	var twoSquarePawn: Square? = nil
}

/**
Represents the state of a game, including all information needed to
determine whether any proposed move is legal.

The default initializer uses the settings that are in effect at the beginning of a game.
*/
struct Position: CustomStringConvertible {
	//MARK: - Properties

	let board: PieceLayout
	let meta: PositionMeta

	init() {
		board = Position.boardForNewGame()
		meta = PositionMeta()
	}

	init(board: PieceLayout, meta: PositionMeta) {
		self.board = board
		self.meta = meta
	}

	//MARK: - Making moves

	func move(from: Square, to: Square) -> Position? {
		return nil
	}

	//MARK: - CustomStringConvertible

	var description: String {
		get {
			return "hello"
		}
	}

	// MARK: Private functions

	private static func boardForNewGame() -> PieceLayout {
		var board = PieceLayout(value: nil)

		for x in 0...7 {
			board[x, 1] = Piece(.White, .Pawn)
			board[x, 6] = Piece(.Black, .Pawn)
		}

		let types: [PieceType] = [.Rook, .Knight, .Bishop, .Queen, .King, .Bishop, .Knight, .Rook]
		for (index, pieceType) in types.enumerated() {
			board[index, 0] = Piece(.White, pieceType)
			board[index, 7] = Piece(.Black, pieceType)
		}

		return board
	}
}

enum MoveType {
	case Plain, PawnTwoSquares, CaptureEnPassant, KingSideCastle, QueenSideCastle
	case PawnPromotion(type: PieceType)
}

struct Move {
	let oldPosition: Position  // The position *preceding* the move.
	let fromSquare: Square
	let toSquare: Square
	let type: MoveType
}

class Game {
	var currentPosition: Position = Position()
	var moves: [Move] = []
	
	
	
}


