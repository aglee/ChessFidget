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
	override var owningGame: Game? {
		didSet {
			if let game = owningGame {
				sendCommandToEngine("setboard \(game.fen)")
			}
		}
	}
	
	/// Used for launching a Sjeng process and exchanging data with it.
	private var processWrapper: ProcessWrapper
	
	private var lineFragment = ""

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
		
		// Limit search depth.
		//
		// NOTE: There's a bug in Sjeng where this command always sets the search depth
		// to 40.  I corrected this in a fork of Apple's Chess.app source code, at
		// <https://github.com/aglee/Chess/commit/dfb16b3f32e5a6633d2119a9fec62cb86d159d00>,
		// and sent them FB17637104.  Until Apple fixes it, the engine will be much
		// stronger than I intended.  I could build a fixed version of sjeng.ChessEngine
		// and embed it in the app, but I don't want to GPL this app.
		sendCommandToEngine("sd 4")   
		
		// Limit search time.
		//
		// NOTE: Sjeng no longer supports this command.
//		sendCommandToEngine("st 1")
		
		// Only search for moves while it is the computer's turn.
		//
		// NOTE: The Sjeng command parser recognizes this command, but it's not listed
		// in "help".  I'm hoping it works.
		sendCommandToEngine("easy")
		
		// Toggles thinking output.
		//
		// NOTE: The Sjeng command parser also recognizes a "nopost" command, though
		// it's not listed in "help".
		sendCommandToEngine("post")
		sendCommandToEngine("nopost")
		
		// Partial workaround for the fact that Sjeng no longer "st" no longer works:
		// make the engine think it's playing on a very short time control.  It'll still
		// be pretty strong but at least it'll play quickly.  Here's what "help" says
		// about the "level" command:
		//
		// level <x>:       the xboard style command to set time
		//   <x> should be in the form: <a> <b> <c> where:
		//   a -> moves to TC (0 if using an ICS style TC)
		//   b -> minutes per game
		//   c -> increment in seconds
		//
		// I see in sjeng.c that the format of the middle argument is %d:%d.
		sendCommandToEngine("level 0 00:10 1")
	}

	deinit {
		processWrapper.terminateProcess()
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
		DispatchQueue.main.async { [weak self] in
			self?.handleDataFromProcessStdout(data)
		}
	}
	
	private func handleDataFromProcessStdout(_ data: Data) {
		// This can be handy when debugging.
		let printLinesReceived = true
		
		// Avoids printing a flood of unhelpful lines that look like ";;; ponder e7e5".
		let includePonderLines = false

		guard data.count > 0 else { return }
		guard let s = stringFromData(data) else {
			print(";;; [WARNING] Could not convert data from stdout to string.")
			lineFragment = ""
			return
		}

		// Split the input into lines.  If we see a line that parses as a valid
		// move by the computer, play that move on the computer's behalf.
		let lines = (lineFragment + s).components(separatedBy: "\n")
		lines.enumerated().forEach { i, line in
			if let move = owningGame?.position.moveFromAlgebraicString(line, reportErrors: false) {
				print(";;; Received move from engine: [\(line)]")
				owningGame?.applyMove(move)
			} else if i < lines.count - 1 {
				if printLinesReceived && (includePonderLines || !line.contains("ponder")) {
					print(";;; \(line)")
				}
			} else {
				// If the data we received ends in the middle of a line, save the partial
				// line so it can be prepended to the next data we receive.
				lineFragment = line
			}
		}
	}

	func didReadFromStderr(_ processWrapper: ProcessWrapper, data: Data) {
		DispatchQueue.main.async { [weak self] in
			self?.handleDataFromProcessStderr(data)
		}
	}
	
	private func handleDataFromProcessStderr(_ data: Data) {
		guard data.count > 0 else { return }
		if let stringFromData = stringFromData(data) {
			print(";;; [stderr]", stringFromData)
		} else {
			print(";;; [WARNING] Could not convert data from stderr to string.")
		}
	}

	func didTerminate(_ processWrapper: ProcessWrapper) {
		DispatchQueue.main.async { [weak self] in
			print(";;; \(type(of: self)) -- process terminated")
		}
	}

	// MARK: - Private methods

	private func stringFromData(_ data: Data) -> String? {
		return String(data: data, encoding: String.Encoding.utf8)
	}

	private func printReceivedData(_ data: Data) {
		guard data.count > 0 else { return }
		
		if let stringFromData = stringFromData(data) {
			print(stringFromData, terminator: "")
		} else {
			print(";;; [WARNING] Could not convert received data to string.")
		}
	}

	private func sendCommandToEngine(_ command: String) {
		assert(processWrapper.isRunning, ";;; The chess engine is not running. Can't send a command to it.")
		let command = command.replacingOccurrences(of: "\n", with: "").lowercased()
		print(";;; sending [\(command)] to the chess engine")
		processWrapper.writeToProcess(command + "\n")
	}
	
}

