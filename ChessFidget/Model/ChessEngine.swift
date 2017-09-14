//
//  ChessEngine.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/13/17.
//  Copyright © 2017 Andy Lee. All rights reserved.
//

import Foundation

/// Communicates with the Sjeng chess engine that comes preinstalled on every Mac.
class ChessEngine: ProcessWrapperDelegate {
	weak var game: Game?

	// Used for launching a Sjeng process and exchanging data with it.
	private var processWrapper: ProcessWrapper

	// MARK: - Init/deinit

	init(game: Game) {
		self.game = game

		let chessEnginePath = "/Applications/Chess.app/Contents/Resources/sjeng.ChessEngine"
		self.processWrapper = ProcessWrapper(launchPath: chessEnginePath, arguments: [])
		self.processWrapper.delegate = self
	}

	// MARK: - Communicating with the chess engine

	func startEngine(makeFirstMove: Bool) {
		self.processWrapper.launchProcess()

		self.sendCommandToEngine("sd 4")  // Limit search depth.
		self.sendCommandToEngine("st 1")  // Limit search time.
		self.sendCommandToEngine("easy")  // Only search for moves while it is the computer's turn.

		if makeFirstMove {
			self.sendCommandToEngine("go")
		}
	}

	// String should be like "d2d4", or "a7a8q".
	func sendEngineHumanMove(_ moveString: String) {
		self.sendCommandToEngine(moveString)
	}

	// MARK: - ProcessWrapperDelegate methods

	func didReadFromStdout(_ processWrapper: ProcessWrapper, data: Data) {
		//self.showReceivedData(data)
		guard let s = stringFromData(data) else { return }
		guard s.count > 0 else { return }

		// If we get a line of text that parses as a valid move by the computer,
		// play that move on the computer's behalf.
		// TODO: Is there any reason to handle other messages the computer might
		// send, like "ponder", "Illegal move", or whatnot?
		// TODO: Should theoretically handle the case where the output from the
		// computer is fragmented across multiple calls to this method, as
		// sometimes happens with the ASCII board representation (which we
		// ignore).  I'm assuming that won't happen with moves, which are always
		// very short strings.
		let lines = s.components(separatedBy: "\n")
		for line in lines {
			if let _ = self.game?.moveFromEngineString(line, reportErrors: false) {
				self.game?.engineDidSendComputerMove(line)
			}
		}
	}

	func didReadFromStderr(_ processWrapper: ProcessWrapper, data: Data) {
		self.showReceivedData(data)
	}

	func didTerminate(_ processWrapper: ProcessWrapper) {
		print(self, "process did terminate")
	}

	// MARK: - Private methods

	private func stringFromData(_ data: Data) -> String? {
		return String(data: data, encoding: String.Encoding.utf8)
	}

	private func showReceivedData(_ data: Data) {
		guard data.count > 0 else {
			return
		}
		if let stringFromData = stringFromData(data) {
			print(stringFromData, terminator: "")
		} else {
			print("+++ [WARNING] Could not convert received data to string.")
		}
	}

	// command should not include a trailing newline.  This method adds it.
	private func sendCommandToEngine(_ command: String) {
		assert(self.processWrapper.isRunning,
		       "The chess engine is not running. Can't send a command to it.")
		print("+++ sending [\(command)] to the chess engine")
		var loweredString = command.lowercased()
		if command.characters.last != "\n" {
			loweredString += "\n"
		}
		self.processWrapper.writeToProcess(loweredString)
	}
}

