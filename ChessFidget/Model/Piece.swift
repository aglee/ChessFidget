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

	var homeRowForPawns: Int {
		return homeRow + forwardDirection
	}
	
	var queeningRow: Int {
		return opponent.homeRow
	}
	
	var debugString: String {
		switch self {
		case .black: return "Black"
		case .white: return "White"
		}
	}
}

// MARK: -
// MARK: -

/// Describes the ways a chess piece can move.
/// - `vectors` contains the smallest possible movements in all directions.
/// - `canRepeat` indicates whether multiples of vectors are allowed.
/// For example, a bishop can go arbitrarily far along one of its diagonal
/// vectors (assuming no obstruction), but a knight can only do one hop along
/// one of its L-shaped vectors.
typealias PieceMovement = (vectors: [VectorXY], canRepeat: Bool)

// MARK: -
// MARK: -

/// Pawn, knight, etc.
enum PieceType {
	case pawn
	case knight
	case bishop
	case rook
	case queen
	case king

	/// Describes the ways the piece can move, except for pawns, whose peculiar
	/// rules cannot be parametrized in this way.  The `vectors` list for pawns
	/// is empty.
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

// MARK: -
// MARK: -

/// A chess piece.
struct Piece: Equatable {
	let color: PieceColor
	let type: PieceType

	private static let piecesForFenCharacters: [Character: Piece] = [
		"P": Piece(.white, .pawn), "R": Piece(.white, .rook), "N": Piece(.white, .knight),
		"B": Piece(.white, .bishop), "Q": Piece(.white, .queen), "K": Piece(.white, .king),
		"p": Piece(.black, .pawn), "r": Piece(.black, .rook), "n": Piece(.black, .knight),
		"b": Piece(.black, .bishop), "q": Piece(.black, .queen), "k": Piece(.black, .king)
	]
	
	var fenCharacter: Character {
		switch color {
		case .white:
			switch type {
			case .pawn: "P"
			case .rook: "R"
			case .knight: "N"
			case .bishop: "B"
			case .queen: "Q"
			case .king: "K"
			}
		case .black:
			switch type {
			case .pawn: "p"
			case .rook: "r"
			case .knight: "n"
			case .bishop: "b"
			case .queen: "q"
			case .king: "k"
			}
		}
	}

	init?(fen: Character) {
		guard let piece = Self.piecesForFenCharacters[fen] else { return nil }
		self.color = piece.color
		self.type = piece.type
	}
	
	init(_ color: PieceColor, _ type: PieceType) {
		self.color = color
		self.type = type
	}

	// MARK: - (Equatable)

	public static func ==(lhs: Piece, rhs: Piece) -> Bool {
		return lhs.color == rhs.color && lhs.type == rhs.type
	}
}

