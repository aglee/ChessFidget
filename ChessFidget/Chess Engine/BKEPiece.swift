//
//  BKEPiece.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/20/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

// Piece info is represented by a bit mask that or's together various piece codes.
typealias BKEPiece = Int
let BKEPiece_NONE = 0

typealias BKEPieceCode = Int

// Rightmost 3 bits indicate the piece type.
let BKEPieceCode_King = 1
let BKEPieceCode_Queen = 2
let BKEPieceCode_Bishop = 3
let BKEPieceCode_Knight = 4
let BKEPieceCode_Rook = 5
let BKEPieceCode_Pawn = 6

// Next bit indicates the piece color.
let BKEPieceCode_White = 0
let BKEPieceCode_Black = 8

// Next bit indicates whether the piece is the result of a promotion.
let BKEPieceCode_Promoted = 16

extension BKEPiece {

	init?(unicodeScalar unicodeScalarForPiece: UnicodeScalar) {
		if unicodeScalarForPiece == UnicodeScalar(" ") {
			return nil
		}
		let unicodeScalars = Array(" KQBNRP  kqbnrp ".unicodeScalars)
		guard let arrayIndex = unicodeScalars.index(of: unicodeScalarForPiece) else {
			return nil
		}
		self.init(integerLiteral: arrayIndex)
	}

	// Extract the piece code -- what kind of piece am I?
	func pieceCode() -> BKEPieceCode { return self & 7 }

	// Returns a piece of the given type, with the same color as self.
	func matching(pieceCode: BKEPieceCode) -> BKEPiece { return (self & 8) | pieceCode }

	// Returns a piece of the same type as self, with the opposite color.
	func opposite() -> BKEPiece { return self ^ 8 }

	// Extract the promoted flag.
	func promoted() -> BKEPieceCode { return self & 16 }

}

