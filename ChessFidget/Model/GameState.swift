//
//  GameState.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/13/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

enum ReasonGameIsOver {
	case BlackWinsByCheckmate
	case WhiteWinsByCheckmate
	case DrawDueToStalemate
	//TODO: Add case DrawDueToInsufficientMaterial
	//TODO: Add case DrawDueTo50MoveRule
}

/**
Currently only used for debugging game flow.  Doesn't enforce any sort of finite state machine, only checks whether the FSM is adhered to implicitly.
*/
enum GameState {
	// MEANING: Waiting for the go-ahead via a call to startPlay() to start the game.  We exit this state by waiting for either the human or the computer to move.  It's possible to transition immediately to gameIsOver if the game was given an initial setup where the player whose turn it is is already in checkmate.
	// TRANSITIONS: awaitingHumanMove, awaitingComputerMove, gameIsOver.
	case awaitingStart

	// MEANING: Waiting for human to express a complete move via input gestures (mouse and/or keyboard).  When that happens, we send the move to the back-end chess engine so the engine can validate the move (even though we will already have done that) and update its (the engine's) state of the game (its representation of the board, etc.).
	// TRANSITIONS: waitingForEngineResponseToHumanMove.
	case awaitingHumanMove

	// MEANING: Waiting for a response from the back-end chess engine.  We expect the move to have been successfully validated by the engine.  We transition when we receive that response.  We may need to explicitly tell the engine to produce the next move -- I'll have to check how the sjeng interface works.
	// TRANSITIONS: awaitingComputerMove, gameIsOver.
	// TODO: Handle the case where the move fails validation by the chess engine.  I'm thinking show something in the UI and change the game state to gameIsOver.  In theory this shouldn't happen, since the UI (again, in theory) only allows the user to make valid moves, but it's worth handling defensively.
	case waitingForEngineResponseToHumanMove

	// MEANING: Waiting for the back-end to send a move to be played by the computer.  We transition when we receive that response.
	// TRANSITIONS: awaitingHumanMove, gameIsOver.
	// TODO: Handle timeouts in case, for example, the engine process crashes.
	case awaitingComputerMove

	// MEANING: The game is over.  No further moves will be processed.  When we enter this state we kill the backend engine.
	// TRANSITIONS: None.
	case gameIsOver
}

