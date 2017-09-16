//
//  Move.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/1/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

/// Each case represents a PieceType that a pawn can possibly be promoted to.
enum PromotionType: Int {
	case promoteToQueen = 0
	case promoteToRook
	case promoteToBishop
	case promoteToKnight

	var pieceType: PieceType {
		switch self {
		case .promoteToQueen: return .queen
		case .promoteToRook: return .rook
		case .promoteToBishop: return .bishop
		case .promoteToKnight: return .knight
		}
	}
}

/// A MoveType is a kind of "metadata" about a move beyond its start and end
/// squares.
enum MoveType {
	/// The common case: move the piece from the start square to the end square,
	/// which might possibly contain an enemy piece being captured.
	case plainMove

	// Special pawn moves.
	case pawnTwoSquares
	case captureEnPassant
	case pawnPromotion(type: PromotionType)

	// Castling, which can be thought of as special king moves.
	case castleKingSide
	case castleQueenSide
}

/// A chess move.
struct Move {
	let start: GridPointXY
	let end: GridPointXY
	let type: MoveType

	init(from start: GridPointXY, to end: GridPointXY, type: MoveType) {
		self.start = start
		self.end = end
		self.type = type
	}

	var debugString: String {
		return "\(start.squareName)-\(end.squareName)"
	}
}

/// Methods for interpreting a GridPointXY as a square on a chessboard.
extension GridPointXY {
	private static let fileCharacters: [Character] = ["a", "b", "c", "d", "e", "f", "g", "h"]
	private static let rankCharacters: [Character] = ["1", "2", "3", "4", "5", "6", "7", "8"]

	/// Returns nil if the string is not a valid two-character algebraic square
	/// notation (uppercase okay).
	init?(algebraic: String) {
		guard let xyPair = GridPointXY.xyFromString(algebraic: algebraic) else {
			return nil
		}

		x = xyPair.x
		y = xyPair.y
	}
	
	/// Converts the point to algebraic chess notation, where (0,0) is "a1" and
	/// (7,7) is h8.
	var squareName: String {
		if x == x % GridPointXY.fileCharacters.count
			&& y == y % GridPointXY.rankCharacters.count {
			return "\(GridPointXY.fileCharacters[x])\(GridPointXY.rankCharacters[y])"
		} else {
			return "GridPointXY(\(x),\(y))"
		}
	}

	// MARK: - Private methods

	private static func xyFromString(algebraic: String) -> (x: Int, y: Int)? {
		let unichars = Array(algebraic.lowercased().unicodeScalars)

		if unichars.count != 2 {
			//print("ERROR: Cannot convert '\(algebraic)' - length must be 2.")
			return nil
		}

		let fileChar = unichars[0]
		let rankChar = unichars[1]

		if fileChar < "a" || fileChar > "h" {
			//print("ERROR: Cannot convert '\(algebraic)' - file character must be in 'a'...'h'.")
			return nil
		}

		if rankChar < "1" || rankChar > "8" {
			//print("ERROR: Cannot convert '\(algebraic)' - rank character must be in '1'...'8'.")
			return nil
		}

		return (x: Int(fileChar.value - UnicodeScalar("a").value),
		        y: Int(rankChar.value - UnicodeScalar("1").value))
	}

}

