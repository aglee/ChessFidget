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

	/// The player whose turn it is, or nil if the game is over.
	var playerToMove: Player? {
		switch gameState {
		case .awaitingMove:
			switch position.whoseTurn {
			case .white: return whitePlayer
			case .black: return blackPlayer
			}
		case .gameIsOver: return nil
		}
	}

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
		let human = HumanPlayer()
		let computer = ChessEngine()
		self.init(white: (humanPlaysWhite ? human : computer),
		          black: (humanPlaysWhite ? computer : human))
	}

	// MARK: - Game play

	func startPlay() {
		generateNextMove()
	}

	/// Assumes the given move is valid for the current position.
	func applyGeneratedMove(_ move: Move) {
		guard let playerToMove = playerToMove else {
			print("+++ [ERROR] Something is screwy -- playerToMove is nil.")
			return
		}
		print("+++ \(move.debugString) (\(move.type)) played by \(position.whoseTurn.debugString) (\(playerToMove.name))")
		position.makeMove(move)
		gameObserver?.gameDidApplyMove(self, move: move, player: playerToMove)
		self.playerToMove?.opponentDidMove(move)  // TODO: Potential for subtle bug because position.makeMove() changes self.playerToMove -- it's a side effect thing.
		generateNextMove()
	}

//	func applyMove(_ moveString: String, from player: Player) {
//		guard let move = position.moveFromAlgebraicString(moveString, reportErrors: true) else {
//			print("ERROR: Couldn't create a Move from the string '\(moveString)'.")
//			return
//		}
//
//		DispatchQueue.main.async {
//			print("+++ about to make computer's move \(move.debugString)")
//			self.makeMove(move, from: player)
//		}
//	}

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

	private func generateNextMove() {
		DispatchQueue.main.async {  // TODO: Is GCD needed?
			self.checkForEndOfGame()
			if case .gameIsOver = self.gameState {
				return
			}
			self.playerToMove?.generateMove()
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
}

