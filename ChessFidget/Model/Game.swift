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

	enum StateOfPlay {
		case awaitingStart
		case awaitingHumanMove
		case awaitingComputerMove
		case gameIsOver
	}

	var position: Position = Position()
	var humanPlayerPieceColor: PieceColor
	var stateOfPlay = StateOfPlay.awaitingStart {
		didSet {
			gameObserver?.gameDidChangeStateOfPlay(self, oldValue: oldValue)
		}
	}
	var gameObserver: GameObserver?

	var engine: ChessEngineWrapper

	// MARK: - Init/deinit

	init(humanPlayerPieceColor: PieceColor) {
		self.humanPlayerPieceColor = humanPlayerPieceColor

		switch humanPlayerPieceColor {
		case .White:
			engine = ChessEngineWrapper.chessEngineWithComputerPlayingBlack()
		case .Black:
			engine = ChessEngineWrapper.chessEngineWithComputerPlayingBlack()
		}
	}

	// MARK: - Game play
	
	func startPlay() {
		guard stateOfPlay == .awaitingStart else {
			return
		}
		awaitTheNextMove()
	}

	// Apply the move to the game, position, and board.  Assumes the given move is valid for the current position.
	func makeMove(_ move: Move) {
		print("\(move.start.squareName)-\(move.end.squareName) (\(move.type)) played by \(position.whoseTurn) (\(position.whoseTurn == humanPlayerPieceColor ? "Human" : "Computer"))")

		position.makeMove(move)
		awaitTheNextMove()

		gameObserver?.gameDidMakeMove(self, move: move)

		//print(position.validMoves().map({ "\($0.start)-\($0.end)" }).sorted())
	}
	
	// MARK: - Private methods

	private func awaitTheNextMove() {
		if position.validMoves.count == 0 {
			stateOfPlay = .gameIsOver
		} else if humanPlayerPieceColor == position.whoseTurn {
			stateOfPlay = .awaitingHumanMove
		} else {
			stateOfPlay = .awaitingComputerMove
			tellTheComputerToMove()
		}
	}

	private func tellTheComputerToMove() {
		assert(stateOfPlay == .awaitingComputerMove, "This method should only be called when the state of play is '\(StateOfPlay.awaitingComputerMove)")

		let validMoves = position.validMoves
		if validMoves.count == 0 {
			stateOfPlay = .gameIsOver
			return
		}

		// For now, just pick a random valid move.
		let moveIndex = Int(arc4random_uniform(UInt32(validMoves.count)))
		makeMove(validMoves[moveIndex])
	}

}

