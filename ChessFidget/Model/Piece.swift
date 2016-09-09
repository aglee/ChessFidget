//
//  Piece.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/24/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

enum PieceColor {
	case Black, White

	var opponent: PieceColor {
		return self == .White ? .Black : .White
	}

	var forwardDirection: Int {
		return self == .White ? 1 : -1
	}

	var homeRow: Int {
		return self == .White ? 0 : 7
	}

	var pawnRow: Int {
		return homeRow + forwardDirection
	}
}

typealias PieceMovement = (vectors: [VectorXY], canRepeat: Bool)

enum PieceType {
	case Pawn
	case Knight
	case Bishop
	case Rook
	case Queen
	case King

	var movement: PieceMovement {
		return PieceType.pieceMovements[self]!
	}

	private static let pieceMovements: [PieceType: PieceMovement] = [
		.Pawn: (vectors: [], canRepeat: false),
		.Knight: (vectors: [(1, 2), (1, -2), (-1, 2), (-1, -2),
		                    (2, 1), (2, -1), (-2, 1), (-2, -1)], canRepeat: false),
		.Bishop: (vectors: [(1, 1), (1, -1), (-1, 1), (-1, -1)], canRepeat: true),
		.Rook: (vectors: [(0, 1), (0, -1), (1, 0), (-1, 0)], canRepeat: true),
		.Queen: (vectors: [(1, 1), (1, -1), (-1, 1), (-1, -1),
		                   (0, 1), (0, -1), (1, 0), (-1, 0)], canRepeat: true),
		.King: (vectors: [(1, 1), (1, -1), (-1, 1), (-1, -1),
		                  (0, 1), (0, -1), (1, 0), (-1, 0)], canRepeat: false),
	]
}

struct Piece: Equatable {
	let color: PieceColor
	let type: PieceType

	init(_ color: PieceColor, _ type: PieceType) {
		self.color = color
		self.type = type
	}

	// MARK: - Equatable protocol

	public static func ==(lhs: Piece, rhs: Piece) -> Bool {
		return lhs.color == rhs.color && lhs.type == rhs.type
	}
}

