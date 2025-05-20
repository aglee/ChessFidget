//
//  GameCompletionState.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/13/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

/// Is the game over or not?
enum GameCompletionState: Equatable {
	case awaitingMove
	case gameOver(reason: ReasonGameIsOver)
}

/// Reasons a game can be over.
enum ReasonGameIsOver: String {
	case blackWinsByCheckmate = "Black wins by checkmate"
	case whiteWinsByCheckmate = "White wins by checkmate"
	case drawDueToStalemate = "Draw due to stalemate"
	//TODO: Add case drawDueToInsufficientMaterial
	//TODO: Add case drawDueTo50MoveRule
	//TODO: Add cases blackDidResign, whiteDidResign
}

