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
		get {
			switch self {
			case .promoteToQueen: return .Queen
			case .promoteToRook: return .Rook
			case .promoteToBishop: return .Bishop
			case .promoteToKnight: return .Knight
			}
		}
	}
}

enum MoveType {
	// The most common case: move the piece from the start square to the end square, which might possibly contain an enemy piece being captured.
	case plain

	// Special pawn moves.
	case pawnTwoSquares
	case captureEnPassant
	case pawnPromotion(type: PromotionType)

	// Castling, which can be thought of as special king moves.
	case castleKingSide
	case castleQueenSide
}

struct Move {
	let start: Square
	let end: Square
	let type: MoveType

	init(from start: Square, to end: Square, type: MoveType) {
		self.start = start
		self.end = end
		self.type = type
	}
}
