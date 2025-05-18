//
//  ChessEngine.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/13/17.
//  Copyright © 2017 Andy Lee. All rights reserved.
//

import Foundation

/// Wrapper around the Sjeng chess engine that comes installed on every Mac.
/// Runs that engine in a subprocess and communicates by command line.
/// 
/// See Apple's source for Chess.app, including source for Sjeng, at
/// <https://github.com/apple-oss-distributions/Chess>.  You can see the
/// supported commands in `sjeng.c`.
class ChessEngine: EnginePlayer, ProcessWrapperDelegate {
	/// Used for launching a Sjeng process and exchanging data with it.
	private var processWrapper: ProcessWrapper

	// MARK: - Init/deinit

	required init() {
		// Initialize properties.
		let oldChessEnginePath = "/Applications/Chess.app/Contents/Resources/sjeng.ChessEngine"
		let chessEnginePath = (FileManager.default.fileExists(atPath: oldChessEnginePath)
							   ? oldChessEnginePath
							   : "/System/" + oldChessEnginePath)
		self.processWrapper = ProcessWrapper(launchPath: chessEnginePath, arguments: [])

		// Call a designated initializer in super.
		super.init(name: "Sjeng Engine")

		// Launch the engine and send initial commands.
		processWrapper.delegate = self
		processWrapper.launchProcess()
		
		// Toggle diagram display.
		sendCommandToEngine("diagram")
		
		// Limit search depth.  NOTE: As of 2025-05-18, there's a bug where this
		// command always sets the search depth to 40.  I corrected this in a fork
		// of Apple's Chess.app source code,
		// at <https://github.com/aglee/Chess/commit/dfb16b3f32e5a6633d2119a9fec62cb86d159d00>,
		// and sent them FB17637104.  Until Apple fixes it, this app will take longer
		// to receive moves than it should, and they will be much stronger than intended.
		// I could build a fixed version and embed it in this app, but I don't want to
		// GPL this app.
		sendCommandToEngine("sd 4")   
		
		// Limit search time.  NOTE: This command is no longer supported.  The prefs pane
		// in Chess.app has a slider for how much time you want the computer to spend on
		// each move, but in practice search depth (the "sd" command mentioned above) is
		// used as a proxy for engine strength.
//		sendCommandToEngine("st 1")
		
		// Only search for moves while it is the computer's turn.  NOTE: This isn't
		// listed in "help", but according to the source code it should work.
		sendCommandToEngine("easy")
		
		// Turns off thinking output.  NOTE: This isn't listed in "help" but according
		// to the source code it should work.
		sendCommandToEngine("nopost")
	}

	// MARK: - Player methods

	override func beginTurn() {
		if let move = owningGame?.moveHistory.last {
			sendCommandToEngine(move.algebraicString)
		} else {
			sendCommandToEngine("go")
		}
	}

	// MARK: - ProcessWrapperDelegate protocol

	func didReadFromStdout(_ processWrapper: ProcessWrapper, data: Data) {
		//printReceivedData(data)  // This is handy to uncomment when debugging.

		guard data.count > 0 else { return }
		guard let s = stringFromData(data) else { return }

		// Split the input into lines.  If we see a line that parses as a valid
		// move by the computer, play that move on the computer's behalf.
		//
		// TODO: Should theoretically handle the case where the output from the
		// computer is fragmented across multiple calls to this method, as
		// sometimes happens with the ASCII board representation (which we
		// ignore).  I'm assuming that won't happen with moves, which are always
		// very short strings.
		let lines = s.components(separatedBy: "\n")
		for line in lines {
			if let move = owningGame?.position.moveFromAlgebraicString(line, reportErrors: false) {
				print(";;; Received move from engine: [\(line)]")
				owningGame?.applyMove(move)
			}
		}
	}

	func didReadFromStderr(_ processWrapper: ProcessWrapper, data: Data) {
		printReceivedData(data)
	}

	func didTerminate(_ processWrapper: ProcessWrapper) {
		print(self, "process did terminate")
	}

	// MARK: - Private methods

	private func stringFromData(_ data: Data) -> String? {
		return String(data: data, encoding: String.Encoding.utf8)
	}

	private func printReceivedData(_ data: Data) {
		guard data.count > 0 else {
			return
		}
		if let stringFromData = stringFromData(data) {
			print(stringFromData, terminator: "")
		} else {
			print(";;; [WARNING] Could not convert received data to string.")
		}
	}

	private func sendCommandToEngine(_ command: String) {
		assert(processWrapper.isRunning,
		       "The chess engine is not running. Can't send a command to it.")
		print(";;; sending [\(command)] to the chess engine")
		// Make sure there's a terminating newline.  Easy to forget it's needed,
		// then wonder why the engine isn't responding.
		var loweredString = command.lowercased()
		if command.last != "\n" {
			loweredString += "\n"
		}
		processWrapper.writeToProcess(loweredString)
	}
	
}

