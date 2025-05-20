//
//  CastlingFlags.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/1/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

enum CastlingSide {
	case kingSide, queenSide
}

struct CastlingFlags: OptionSet {
	let rawValue: Int
	
	static let whiteKingSide  = CastlingFlags(rawValue: 1 << 0)
	static let whiteQueenSide = CastlingFlags(rawValue: 1 << 1)
	static let blackKingSide  = CastlingFlags(rawValue: 1 << 2)
	static let blackQueenSide = CastlingFlags(rawValue: 1 << 3)
	
	static let allCastlingAllowed: CastlingFlags = [.whiteKingSide, .whiteQueenSide,
													.blackKingSide, .blackQueenSide]

	var fenNotation: String {
		let flagsString = ((contains(.whiteKingSide) ? "K" : "") +
						   (contains(.whiteQueenSide) ? "Q" : "") +
						   (contains(.blackKingSide) ? "k" : "") +
						   (contains(.blackQueenSide) ? "q" : ""))
		return flagsString.isEmpty ? "-" : flagsString
	}

	mutating func disableCastling(_ pieceColor: PieceColor) {
		disableCastling(pieceColor, .kingSide)
		disableCastling(pieceColor, .queenSide)
	}

	mutating func disableCastling(_ color: PieceColor, _ side: CastlingSide) {
		switch (color, side) {
		case (.white, .kingSide): remove(.whiteKingSide)
		case (.white, .queenSide): remove(.whiteQueenSide)
		case (.black, .kingSide): remove(.blackKingSide)
		case (.black, .queenSide): remove(.blackQueenSide)
		}
	}

	func canCastle(_ color: PieceColor, _ side: CastlingSide) -> Bool {
		return switch (color, side) {
		case (.white, .kingSide): contains(.whiteKingSide)
		case (.white, .queenSide): contains(.whiteQueenSide)
		case (.black, .kingSide): contains(.blackKingSide)
		case (.black, .queenSide): contains(.blackQueenSide)
		}
	}
}

