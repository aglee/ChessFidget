//
//  Piece.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/24/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

/// The side being played by a chess player, either White or Black.
enum PieceColor: Int {
	case black, white

	var opponent: PieceColor {
		return self == .white ? .black : .white
	}

	/// Either 1 or -1, depending on the direction in which this color's pawns
	/// move.
	var forwardDirection: Int {
		return self == .white ? 1 : -1
	}

	var homeRow: Int {
		return self == .white ? 0 : 7
	}

	var pawnRow: Int {
		return homeRow + forwardDirection
	}

	var debugString: String {
		switch self {
		case .black: return "Black"
		case .white: return "White"
		}
	}
}

/// Directions in which a piece can move, and whether it can do so repeatedly.
/// For example, bishops can repeat the vector but knights can't.
typealias PieceMovement = (vectors: [VectorXY], canRepeat: Bool)

/// Pawn, knight, etc.
enum PieceType {
	case pawn
	case knight
	case bishop
	case rook
	case queen
	case king

	var movement: PieceMovement {
		return PieceType.pieceMovements[self]!
	}

	private static let pieceMovements: [PieceType: PieceMovement] = [
		.pawn: (vectors: [], canRepeat: false),
		.knight: (vectors: [(1, 2), (1, -2), (-1, 2), (-1, -2),
		                    (2, 1), (2, -1), (-2, 1), (-2, -1)], canRepeat: false),
		.bishop: (vectors: [(1, 1), (1, -1), (-1, 1), (-1, -1)], canRepeat: true),
		.rook: (vectors: [(0, 1), (0, -1), (1, 0), (-1, 0)], canRepeat: true),
		.queen: (vectors: [(1, 1), (1, -1), (-1, 1), (-1, -1),
		                   (0, 1), (0, -1), (1, 0), (-1, 0)], canRepeat: true),
		.king: (vectors: [(1, 1), (1, -1), (-1, 1), (-1, -1),
		                  (0, 1), (0, -1), (1, 0), (-1, 0)], canRepeat: false),
	]
}


/// A chess piece.
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

