//
//  Move.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/25/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

enum MoveType {
	case Plain, PawnTwoSquares, CaptureEnPassant, KingSideCastle, QueenSideCastle
	case PawnPromotion(type: PieceType)
}

/**
Technically a misnomer.  This actually represents one "turn", or "ply".
*/
struct Move {
	let fromSquare: Square
	let toSquare: Square
	var promotion: PieceType? = nil

	init(from fromSquare: Square, to toSquare: Square, promotion: PieceType? = nil) {
		self.fromSquare = fromSquare
		self.toSquare = toSquare
		self.promotion = promotion
	}
}

