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
	static let didAddMove = Notification.Name("GameDidAddMoveNotification")

	private(set) var position: Position
	private(set) var completionState: GameCompletionState
	private(set) var whitePlayer: Player
	private(set) var blackPlayer: Player
	private(set) var moveHistory: [Move] = []
	private(set) var movesWithoutCaptureOrPawnAdvance = 0  // Should this be here or in Position?

	var fenNotation: String {
		let pieces = position.board.fenNotation
		let activeColor = position.whoseTurn == .white ? "w" : "b"
		let castling = position.castlingFlags.fenNotation
		
		// In FEN notation, this is the square the pawn passed over, not the square
		// where it landed.
		let enPassantPoint: String
		if let ep = position.enPassantableGridPoint {
			enPassantPoint = (ep.y == 3
							  ? GridPointXY(ep.x, 2).squareName
							  : GridPointXY(ep.x, 5).squareName)
		} else {
			enPassantPoint = "-"
		}

		let halfMoveClock = String(movesWithoutCaptureOrPawnAdvance)
		let fullMoveNumber = String(max(1, (moveHistory.count + 1) / 2))
		
		return String(format: "%@ %@ %@ %@ %@ %@", pieces, activeColor, castling, enPassantPoint, halfMoveClock, fullMoveNumber)
	}
	
	// MARK: - Lifecycle

	/// Standard game setup, with all pieces on their home squares, with White
	/// to move.
	init(white: Player, black: Player, board: Board = Board.withClassicalLayout()) {
		self.position = Position(board: board)
		self.completionState = .awaitingMove
		self.whitePlayer = white
		self.blackPlayer = black

		// Make these connections last, because the Player objects may need to know stuff
		// like what the board arrangement is before they can begin play.
		self.whitePlayer.game = self
		self.blackPlayer.game = self
	}

	// MARK: - Game play

	func startPlay() {
		checkWhetherGameIsOver()
		if case .awaitingMove = completionState {
			whitePlayer.beginTurn()
		}
	}

	func validateMove(from startPoint: GridPointXY, to endPoint: GridPointXY) -> MoveValidity {
		let validator = MoveValidator(position: position, startPoint: startPoint, endPoint: endPoint)
		return validator.validateMove()
	}

	/// Each `EnginePlayer` must call this method when it has finished generating the
	/// move it wants to make.
	func applyMove(_ move: Move) {
		if case .gameOver = completionState {
			print(";;; Game is over. Move will be ignored.")
			return
		}

		// We're only checking start and end points here, not the move type, but this is
		// probably good enough.
		guard case .valid = validateMove(from: move.start, to: move.end) else {
			assert(false, "Move \(move.debugString) is invalid")
		}

		let playerWhoMoved = (position.whoseTurn == .white ? whitePlayer : blackPlayer)
		let playerWhoMovesNext = (position.whoseTurn == .white ? blackPlayer : whitePlayer)

		print(";;; \(move.debugString) (\(move.type)) played by \(position.whoseTurn.debugString) (\(playerWhoMoved.name))")
		if position.board[move.start]?.type == .pawn || position.board[move.end] != nil {
			movesWithoutCaptureOrPawnAdvance = 0
		} else {
			movesWithoutCaptureOrPawnAdvance += 1
		}
		position.makeMoveAndSwitchTurn(move)
		moveHistory.append(move)
		checkWhetherGameIsOver()
		NotificationCenter.default.post(name: Self.didAddMove, object: self)
		if case .awaitingMove = completionState {
			playerWhoMovesNext.beginTurn()
		}
	}

	// MARK: - Private methods

	// Checks whether the game is over.  If so, sets `completionState`.
	private func checkWhetherGameIsOver() {
		// If we already know the game is over, no need to check again.
		if case .gameOver = completionState {
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
		completionState = .gameOver(reason: gameEndReason)
	}

}

