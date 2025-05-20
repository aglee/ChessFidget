//
//  Position.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/25/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

import Foundation

/// Represents the state of a chess game, including all information needed to determine
/// whether any proposed move is legal.
struct Position {
	var board: Board
	var whoseTurn = PieceColor.white
	var enPassantableGridPoint: GridPointXY? = nil
	var castlingFlags = CastlingFlags()

	var canCastleKingSide: Bool {
		return castlingFlags.canCastleKingSide(whoseTurn)
	}

	var canCastleQueenSide: Bool {
		return castlingFlags.canCastleQueenSide(whoseTurn)
	}

	var validMoves: [Move] {
		return MoveGenerator(position: self).allValidMoves
	}

	init(board: Board) {
		self.board = board
	}

	/// Assumes `move` is valid for the current player and the current state of
	/// the board, and that it is correctly characterized by its `type`.
	mutating func makeMoveAndSwitchTurn(_ move: Move) {
		// Update the pieces on the board.
		board.makeMove(from: move.start, to: move.end, type: move.type)

		// Update en passant info.
		if case .pawnTwoSquares = move.type {
			enPassantableGridPoint = move.end
		} else {
			enPassantableGridPoint = nil
		}

		// Update castling flags if a king or rook is leaving its home square.
		func castlingFlagToInsert() -> CastlingFlags? {
			guard move.start.y == whoseTurn.homeRow else { return nil }
			return switch move.start.x {
			case 0: (whoseTurn == .white ? .whiteQueenRookHasMoved : .blackQueenRookHasMoved)
			case 4: (whoseTurn == .white ? .whiteKingHasMoved : .blackKingHasMoved)
			case 7: (whoseTurn == .white ? .whiteKingRookHasMoved : .blackKingRookHasMoved)
			default: nil
			}
		}
		if let flag = castlingFlagToInsert() { castlingFlags.insert(flag) }

		// It's the other player's turn now.
		whoseTurn = whoseTurn.opponent
	}

	/// Converts a string like "e2e4" or "a7a8q" into a Move instance.  If the
	/// input string does not represent a valid move, returns nil.
	func moveFromAlgebraicString(_ algebraic: String, reportErrors: Bool) -> Move? {
		var str = algebraic.lowercased() as NSString
		if str.hasSuffix("\n") {
			str = str.substring(to: str.length - 1) as NSString
		}

		guard str.length == 4 || str.length == 5 else {
			if reportErrors {
				print(";;; ERROR: Engine string '\(str)' has unexpected length.")
			}
			return nil
		}

		let startPointString = str.substring(with: NSMakeRange(0, 2))
		guard let startPoint = GridPointXY(algebraic: startPointString) else {
			if reportErrors {
				print(";;; ERROR: Engine string '\(str)' has invalid start square.")
			}
			return nil
		}

		let endPointString = str.substring(with: NSMakeRange(2, 2))
		guard let endPoint = GridPointXY(algebraic: endPointString) else {
			if reportErrors {
				print(";;; ERROR: Engine string '\(str)' has invalid end square.")
			}
			return nil
		}

		let validity = MoveValidator(position: self,
		                             startPoint: startPoint,
		                             endPoint: endPoint).validateMove()
		switch validity {
		case .invalid(_):
			return nil
		case .valid(let moveType):
			if case .pawnPromotion(_) = moveType {
				assert(str.length == 5, "ERROR: Engine string '\(str)' represents a pawn promotion, but does not specify the piece to promote to.")
				let promoType: PromotionType
				switch str.substring(from: 4).lowercased() {
				case "b": promoType = .promoteToBishop
				case "n": promoType = .promoteToKnight
				case "r": promoType = .promoteToRook
				case "q": promoType = .promoteToQueen
				default:
					fatalError("Unexpected promotion type in move string '\(str)' received from the engine.")
				}
				return Move(from: startPoint, to: endPoint, type: .pawnPromotion(type: promoType))
			} else {
				return Move(from: startPoint, to: endPoint, type: moveType)
			}
		}
	}
}

