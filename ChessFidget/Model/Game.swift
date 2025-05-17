//
//  Game.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/25/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

import Foundation


// NOTE TO SELF: I'm trying to design this class with the idea that in the
// future I might want to add the option to instantiate a `Game` with a
// different initial board (possibly already in a mated/drawn position), and/or
// with Black to move.


/// Represents a chess game.  Players are represented by instances of `Player`
/// subclasses.
class Game {
	private(set) var position: Position
	private(set) var gameState: GameState
	private(set) var whitePlayer: Player
	private(set) var blackPlayer: Player
	private(set) var moveHistory: [Move] = []

	var gameObserver: GameObserver?

	/// Standard game setup, with all pieces on their home squares, with White
	/// to move.
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
			self.init(white: HumanPlayer(), black: ChessEngine())
		} else {
			self.init(white: ChessEngine(), black: HumanPlayer())
		}
	}

	// MARK: - Game play

	func startPlay() {
		checkForEndOfGame()
		if case .awaitingMove = gameState {
			whitePlayer.beginTurn()
		}
	}

	/// Each `Player` must call this method when it has finished generating the
	/// move it wants to make.  This method assumes `move` is a legal move for
	/// the player whose turn it is in the current position.
	func applyGeneratedMove(_ move: Move) {
		if case .gameIsOver = gameState {
			print(";;; Game is over. Move will be ignored.")
			return
		}

		let playerWhoMoved = (position.whoseTurn == .white ? whitePlayer : blackPlayer)
		let playerWhoMovesNext = (position.whoseTurn == .white ? blackPlayer : whitePlayer)

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			print(";;; \(move.debugString) (\(move.type)) played by \(position.whoseTurn.debugString) (\(playerWhoMoved.name))")
			position.makeMoveAndSwitchTurn(move)
			moveHistory.append(move)
			gameObserver?.gameDidApplyMove(self, move: move, player: playerWhoMoved)
			checkForEndOfGame()
			if case .awaitingMove = gameState {
				playerWhoMovesNext.beginTurn()
			}
		}
	}

//	func engineDidApproveHumanMove(_ moveString: String) {
//		print(";;; \(type(of: self)).\(#function) -- \(moveString)")
//	}

	func assertExpectedGameState(_ expectedGameState: GameState) {
		assert("\(gameState)" == "\(expectedGameState)", "Expected game state to be '\(expectedGameState)'.")
	}

	// MARK: - Private methods

	// Checks whether the game is over.  If so, sets `gameState`.
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
		print(";;; game is over -- \(gameEndReason)")
		gameState = .gameIsOver(reason: gameEndReason)
		gameObserver?.gameDidEnd(self, reason: gameEndReason)
	}

}

