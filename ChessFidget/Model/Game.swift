//
//  Game.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/25/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

import Foundation

/// Represents a chess game.  Players are represented by instances of `Player`
/// subclasses.
class Game {
	private(set) var position: Position
	private(set) var gameState: GameState
	private(set) var whitePlayer: Player
	private(set) var blackPlayer: Player

	var gameObserver: GameObserver?

	/// Standard game setup, with all pieces in their home squares, with White
	/// to move.
	///
	/// NOTE TO SELF: Currently this is the only initializer, but I'm trying
	/// to design this class with the idea that in the future I might want to
	/// add the option to instantiate a `Game` with a different initial board
	/// (possibly already in a mated/drawn position), and/or with Black to move.
	init(white: Player, black: Player) {
		self.position = Position()
		self.gameState = .awaitingMove
		self.whitePlayer = white
		self.blackPlayer = black

		self.whitePlayer.owningGame = self
		self.blackPlayer.owningGame = self
	}

	convenience init(humanPlaysWhite: Bool) {
		if humanPlaysWhite {
			self.init(white: HumanPlayer(),
			          black: ChessEngine(makeFirstMove: false))
		} else {
			self.init(white: ChessEngine(makeFirstMove: true),
			          black: HumanPlayer())
		}
	}

	// MARK: - Game play

	func startPlay() {
		self.checkForEndOfGame()
	}

	/// Each `Player` must call this method when it has finished generating the
	/// move it wants to make.  This method assumes `move` is a legal move for
	/// the player whose turn it is in the current position.
	func applyGeneratedMove(_ move: Move) {
		if case .gameIsOver = gameState {
			print("+++ Game is over. Move will be ignored.")
			return
		}

		let playerWhoMoved = (position.whoseTurn == .white ? whitePlayer : blackPlayer)
		let playerWhoMovesNext = (position.whoseTurn == .white ? blackPlayer : whitePlayer)

		DispatchQueue.main.async {
			print("""
				+++ \(move.debugString) (\(move.type)) \
				played by \(self.position.whoseTurn.debugString) \
				(\(playerWhoMoved.name))
				""")
			self.position.makeMove(move)
			self.gameObserver?.gameDidApplyMove(self, move: move, player: playerWhoMoved)
			playerWhoMovesNext.opponentDidMove(move)
			self.checkForEndOfGame()
		}
	}

//	func engineDidApproveHumanMove(_ moveString: String) {
//		print("+++ \(type(of: self)).\(#function) -- \(moveString)")
//	}

	func assertExpectedGameState(_ expectedGameState: GameState) {
		assert("\(gameState)" == "\(expectedGameState)", "Expected game state to be '\(expectedGameState)'.")
	}

	// MARK: - Private methods

	// Checks whether the game is over.  If so, sets `self.gameState`.
	func checkForEndOfGame() {
		// If we already know the game is over, no need to check again.
		if case .gameIsOver = gameState {
			return
		}

		// If any valid moves can still be made, the game is not over.
		if position.validMoves.count > 0 {
			return
		}

		// We now know the game is over.  What's the reason?
		let gameEndReason: ReasonGameIsOver
		if position.board.isInCheck(position.whoseTurn) {
			switch position.whoseTurn {
			case .black: gameEndReason = .whiteWinsByCheckmate
			case .white: gameEndReason = .blackWinsByCheckmate
			}
		} else {
			gameEndReason = .drawDueToStalemate
		}
		print("+++ game is over -- \(gameEndReason)")
		gameState = .gameIsOver(reason: gameEndReason)
		gameObserver?.gameDidEnd(self, reason: gameEndReason)
	}

//		if humanPlayerPieceColor == position.whoseTurn {
//			// It's the human's turn.  Nothing further to do except wait for
//			// them to interact with the UI.
//			gameState = .awaitingHumanMove
//		} else {
//			// It's the computer's turn.  If we aren't using AI, select a random
//			// valid move and have the computer make it.  If we *are* using AI,
//			// there is nothing further to do -- the chess engine is already
//			// "thinking" and we will get notified when it tells us its move.
//			gameState = .awaitingComputerMove
//
//			if computerPlaysRandomly {
//				let validMoves = position.validMoves
//				let delay = 0.1
//				let when = DispatchTime.now() + delay  //[agl] Why did I add a delay?
//				DispatchQueue.main.asyncAfter(deadline: when, execute: {
//					let moveIndex = Int(arc4random_uniform(UInt32(validMoves.count)))
//					self.makeMove(validMoves[moveIndex])
//				})
//			}
//		}


}

