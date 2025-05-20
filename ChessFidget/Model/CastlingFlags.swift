//
//  CastlingFlags.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/1/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

/// Flags indicating whether any of the kings or rooks have left their home squares.
struct CastlingFlags: OptionSet {
	let rawValue: Int
	
	static let whiteQueenRookHasMoved = CastlingFlags(rawValue: 1 << 0)
	static let whiteKingHasMoved      = CastlingFlags(rawValue: 1 << 1)
	static let whiteKingRookHasMoved  = CastlingFlags(rawValue: 1 << 2)
	static let blackQueenRookHasMoved = CastlingFlags(rawValue: 1 << 3)
	static let blackKingHasMoved      = CastlingFlags(rawValue: 1 << 4)
	static let blackKingRookHasMoved  = CastlingFlags(rawValue: 1 << 5)
	
	var fenNotation: String {
		let flagsString = ((canCastleKingSide(.white) ? "K" : "") +
						   (canCastleQueenSide(.white) ? "Q" : "") +
						   (canCastleKingSide(.black) ? "k" : "") +
						   (canCastleQueenSide(.black) ? "q" : ""))
		return flagsString.isEmpty ? "-" : flagsString
	}
	
	func canCastleKingSide(_ pieceColor: PieceColor) -> Bool {
		return switch pieceColor {
		case .white: !contains(.whiteKingHasMoved) && !contains(.whiteKingRookHasMoved)
		case .black: !contains(.blackKingHasMoved) && !contains(.blackKingRookHasMoved)
		}
	}
	
	func canCastleQueenSide(_ pieceColor: PieceColor) -> Bool {
		return switch pieceColor {
		case .white: !contains(.whiteKingHasMoved) && !contains(.whiteQueenRookHasMoved)
		case .black: !contains(.blackKingHasMoved) && !contains(.blackQueenRookHasMoved)
		}
	}
}

