//
//  Game.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/25/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

import Foundation

/**
Game play alternates between the human player and the computer.
*/
@objc class Game: NSObject {

	var position: Position = Position()
	var humanPlayerPieceColor: PieceColor
	var gameState: GameState = .awaitingStart {
		didSet {
			gameObserver?.gameDidChangeState(self, oldValue: oldValue)
		}
	}
	var gameObserver: GameObserver?
	var engineWrapper: ChessEngineWrapper

	// MARK: - Init/deinit

	init(humanPlayerPieceColor: PieceColor) {
		self.humanPlayerPieceColor = humanPlayerPieceColor

		switch humanPlayerPieceColor {
		case .White:
			engineWrapper = ChessEngineWrapper.chessEngineWithComputerPlayingBlack()
		case .Black:
			engineWrapper = ChessEngineWrapper.chessEngineWithComputerPlayingWhite()
		}

		super.init()

		engineWrapper.game = self
	}

	// MARK: - Game play

	func startPlay() {
		guard case .awaitingStart = gameState else {
			print("NOTE: \(#function) expects game state to be \(GameState.awaitingStart)")
			return
		}
		awaitTheNextMove()
	}

	func makeHumanMove(_ move: Move) {
		makeMove(move)

		var moveStringForEngine = "\(move.start.squareName)\(move.end.squareName)"
		if case .pawnPromotion(let promoType) = move.type {
			switch promoType {
			case .promoteToBishop: moveStringForEngine = moveStringForEngine + "b"
			case .promoteToKnight: moveStringForEngine = moveStringForEngine + "n"
			case .promoteToRook: moveStringForEngine = moveStringForEngine + "r"
			case .promoteToQueen: moveStringForEngine = moveStringForEngine + "q"
			}
		}
		engineWrapper.sendEngineHumanMove(moveStringForEngine)
	}
	
	func humanMoveWasApproved(_ moveString: String) {
		print("+++ \(type(of: self)) \(#function): \(moveString)")
	}

	func computerMoveWasReceived(_ moveString: String) {
		print("+++ \(type(of: self)) \(#function): \(moveString)")

		guard let move = moveFromEngineString(moveString) else {
			print("ERROR: Couldn't create a Move from the string '\(moveString)'.")
			return
		}

		DispatchQueue.main.async {
			print("+++ about to make computer's move \(move.debugString)")
			self.makeMove(move)
		}
	}

	// MARK: - Private methods

	// Apply the move to the game, position, and board.  Assumes the given move is valid for the current position.
	private func makeMove(_ move: Move) {
		print("+++ \(move.debugString) (\(move.type)) played by \(position.whoseTurn.debugString) (\(position.whoseTurn == humanPlayerPieceColor ? "Human" : "Computer"))")

		position.makeMove(move)
		gameObserver?.gameDidMakeMove(self, move: move)

		awaitTheNextMove()
	}
	
	private func moveFromEngineString(_ engineString: String) -> Move? {
		var str = engineString.lowercased() as NSString
		if str.hasSuffix("\n") {
			str = str.substring(to: str.length - 1) as NSString
		}

		guard str.length == 4 || str.length == 5 else {
			print("ERROR: Engine string '\(str)' has unexpected length.")
			return nil
		}

		guard let startPoint = GridPointXY(algebraic: str.substring(with: NSMakeRange(0, 2))) else {
			print("ERROR: Engine string '\(str)' has invalid start square.")
			return nil
		}

		guard let endPoint = GridPointXY(algebraic: str.substring(with: NSMakeRange(2, 2))) else {
			print("ERROR: Engine string '\(str)' has invalid end square.")
			return nil
		}

		let validity = MoveValidator(position: position, startPoint: startPoint, endPoint: endPoint).validateMove()
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

	private func seeIfGameIsAutomaticallyOver() -> ReasonGameIsOver? {
		if position.validMoves.count > 0 {
			return nil
		}

		if position.board.isInCheck(position.whoseTurn) {
			switch position.whoseTurn {
			case .Black: return .WhiteWinsByCheckmate
			case .White: return .BlackWinsByCheckmate
			}
		}

		return .DrawDueToStalemate
	}

	private func awaitTheNextMove() {
		if let reason = seeIfGameIsAutomaticallyOver() {
			print("game is over -- \(reason)")
			gameState = .gameIsOver
		} else if humanPlayerPieceColor == position.whoseTurn {
			gameState = .awaitingHumanMove
		} else {
			gameState = .awaitingComputerMove
			tellTheComputerToMove()
		}
	}

	private func tellTheComputerToMove() {
		assert(gameState == .awaitingComputerMove, "This method should only be called when the game state is '\(GameState.awaitingComputerMove)'")

		let validMoves = position.validMoves
		if validMoves.count == 0 {
			gameState = .gameIsOver
			return
		}

		// For now, just pick a random valid move.
//		let delay = 0.1
//		let when = DispatchTime.now() + delay
//		DispatchQueue.main.asyncAfter(deadline: when, execute: {
//			let moveIndex = Int(arc4random_uniform(UInt32(validMoves.count)))
//			self.makeMove(validMoves[moveIndex])
//		})
	}

}

