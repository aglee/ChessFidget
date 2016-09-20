//
//  Move.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/1/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

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

enum MoveType {
	// The most common case: move the piece from the start square to the end square, which might possibly contain an enemy piece being captured.
	case plainMove

	// Special pawn moves.
	case pawnTwoSquares
	case captureEnPassant
	case pawnPromotion(type: PromotionType)

	// Castling, which can be thought of as special king moves.
	case castleKingSide
	case castleQueenSide
}

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

	// Converts the point to algebraic chess notation, where (0,0) is "a1" and (7,7) is h8.
	var squareName: String {
		if x == x % GridPointXY.fileCharacters.count
			&& y == y % GridPointXY.rankCharacters.count {
			return "\(GridPointXY.fileCharacters[x])\(GridPointXY.rankCharacters[y])"
		} else {
			return "GridPointXY(\(x),\(y))"
		}
	}

}

