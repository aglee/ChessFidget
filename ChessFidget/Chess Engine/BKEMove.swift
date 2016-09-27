//
//  BKEMove.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/20/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

enum BKEMoveCode: Int {
	case kCmdNull,
	kCmdMove, 		kCmdDrop, 		kCmdUndo,
	kCmdWhiteWins, 	kCmdBlackWins, 	kCmdDraw,
	kCmdPong, 		kCmdStartGame,
	kCmdPMove,		kCmdPDrop,
	kCmdMoveOK
};

// The value of a BKESquare is either BKESquare_Invalid or a 6-bit number encoding row and column.
typealias BKESquare = Int
let BKESquare_Invalid = 0xFF

extension BKESquare {

	private static let columnChars = ["a", "b", "c", "d", "e", "f", "g", "h"]

	init(colrow: String) {
		let unicodeScalars = Array(colrow.unicodeScalars)
		let columnIndex = Int(unicodeScalars[0].value - UnicodeScalar("a").value)
		let rowIndex = Int(unicodeScalars[1].value - UnicodeScalar("1").value)

		self.init(integerLiteral: ((rowIndex << 3) | columnIndex))
	}

	// Rightmost 3 bits indicate the column.
	var columnCharacter: String { return BKESquare.columnChars[self & 7] }

	// Next 3 bits indicate the row.
	var rowCharacter: String { return String(1 + (self >> 3)) }

}

enum BKESide {
	case whiteSide, blackSide, bothSides, neitherSide
}

//
// A compact move has a very short existence and is only used in places
// where the information absolutely has to be kept to 32 bits.
//
typealias BKECompactMove = Int

struct BKEMove {
	var command: BKEMoveCode
	var fromSquare: BKESquare
	var toSquare: BKESquare
	var piece: BKEPiece
	var promotion: BKEPiece
	var capturedPiece: BKEPiece

	init(command: BKEMoveCode) {
		self.command		= command
		self.fromSquare		= BKESquare_Invalid
		self.toSquare		= BKESquare_Invalid
		self.piece			= BKEPiece_NONE
		self.promotion		= BKEPiece_NONE
		self.capturedPiece	= BKEPiece_NONE
	}

	init(compactMove: BKECompactMove) {
		self.init(command: BKEMoveCode(rawValue: compactMove >> 24)!)

		switch (self.command) {
		case .kCmdMove, .kCmdPMove:
			self.fromSquare	= (compactMove >> 16) & 0xFF;
			self.toSquare	= (compactMove >> 8)  & 0xFF;
			self.promotion	= compactMove & 0xFF;
		case .kCmdDrop, .kCmdPDrop:
			self.toSquare	= (compactMove >> 8)  & 0xFF;
			self.piece		= compactMove & 0xFF;
		default:
			break;
		}
	}

	init(engineMove: String) {
		let unicodeScalars = Array(engineMove.unicodeScalars)
		if unicodeScalars[1] == UnicodeScalar("@") {
			self.init(command: .kCmdDrop)

			self.piece = BKEPiece(unicodeScalar: unicodeScalars[0])!
			self.toSquare = BKESquare(colrow: (engineMove as NSString).substring(from: 2))
		} else {
			self.init(command: .kCmdMove)

			self.fromSquare = BKESquare(colrow: engineMove)
			self.toSquare = BKESquare(colrow: (engineMove as NSString).substring(from: 2))

			if unicodeScalars.count > 4 {
				self.promotion	= BKEPiece(unicodeScalar: unicodeScalars[4])!
			}
		}
	}

	var engineMove: String {
		return "\(engineMoveWithoutNewline)\n"
	}

	var engineMoveWithoutNewline: String {
		let pieceCharacters = " KQBNRP  kqbnrp ".unicodeScalars.map({ return String($0) })

		switch self.command {
		case .kCmdMove:
			if self.promotion != 0 {
				return
					self.fromSquare.columnCharacter + self.fromSquare.rowCharacter
						+ self.toSquare.columnCharacter + self.toSquare.rowCharacter
						+ pieceCharacters[self.promotion & 15]
			} else {
				return
					self.fromSquare.columnCharacter + self.fromSquare.rowCharacter
						+ self.toSquare.columnCharacter + self.toSquare.rowCharacter
			}
		case .kCmdDrop:
			return
				pieceCharacters[self.piece & 15]
					+ self.toSquare.columnCharacter + self.toSquare.rowCharacter
		default:
			return "???????"
		}
	}

}

