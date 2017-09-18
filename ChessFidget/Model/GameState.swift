//
//  GameState.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/13/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

enum ReasonGameIsOver: String {
	case blackWinsByCheckmate = "Black wins by checkmate"
	case whiteWinsByCheckmate = "White wins by checkmate"
	case drawDueToStalemate = "Draw due to stalemate"
	//TODO: Add case drawDueToInsufficientMaterial
	//TODO: Add case drawDueTo50MoveRule
}

/// Used for keeping track of game flow and performing sanity checks (are we
/// trying to do something we shouldn't be doing given the current game state?).
enum GameState {
	case awaitingGameStart
	case awaitingMove(player: Player)
	case gameIsOver(reason: ReasonGameIsOver)
}

