//
//  ProcessWrapper.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/13/17.
//  Copyright © 2017 Andy Lee. All rights reserved.
//

import Foundation

/// Convenience wrapper around the `Foundation.Process` class.
/// - To **launch** the process, call `launchProcess()`.
/// - To **receive** data from the process, set up a delegate.
/// - To **send** data to the process, use the `writeToProcess` methods.
/// - To **terminate** the process, call `terminateProcess()`.
class ProcessWrapper {
	weak var delegate: (AnyObject & ProcessWrapperDelegate)?
	let launchPath: String
	let arguments: [String]

	var isRunning: Bool {
		if let p = process {
			return p.isRunning
		} else {
			return false
		}
	}

	private var process: Process? = nil
	private var isObserving: Bool = false

	private var processStdin: Pipe { return process?.standardInput as! Pipe }
	private var processStdout: Pipe { return process?.standardOutput as! Pipe }
	private var processStderr: Pipe { return process?.standardError as! Pipe }

	// MARK: - Init/deinit

	init(launchPath: String, arguments: [String]) {
		self.launchPath = launchPath
		self.arguments = arguments
	}

	deinit {
		stopObserving()
		process?.terminate()
	}

	// MARK: - Interacting with the process

	func launchProcess() {
		if let _ = process {
			print("Process is already running.")
			return
		}

		// Set up a Process object.
		let p = Process()
		p.launchPath = launchPath
		p.arguments = arguments
		let inputPipe = Pipe()
		let outputPipe = Pipe()
		let errorPipe = Pipe()
		p.standardInput = inputPipe
		p.standardOutput = outputPipe
		p.standardError = errorPipe
		inputPipe.fileHandleForWriting.readInBackgroundAndNotify()
		outputPipe.fileHandleForReading.readInBackgroundAndNotify()
		outputPipe.fileHandleForReading.readInBackgroundAndNotify()

		// Connect to that Process object.
		process = p
		startObserving()

		// Launch the process.
		p.launch()
	}

	/// Sends data to the process's standard input.
	func writeToProcess(_ data: Data) {
		guard data.count > 0 else { return }
		guard let p = process else {
			print(";;; [ERROR] Process is not running, cannot send data to it.")
			return
		}
		guard p.isRunning else {
			print(";;; [ERROR] Process has been terminated, cannot send data to it.")
			return
		}
		processStdin.fileHandleForWriting.write(data)
	}

	/// Sends UTF-8 data to the process's standard input.
	func writeToProcess(_ string: String) {
		if let d = string.data(using: String.Encoding.utf8) {
			writeToProcess(d)
		}
	}

	/// Kills the process.  The receiver can then launch a new process; unlike
	/// `Process`, `ProcessWrapper` is reusable.
	func terminateProcess() {
		process?.terminate()
		process = nil
	}

	// MARK: - Notification handlers

	@objc private func didReadFromProcessStdout(_ note: Notification) {
		// Inform the delegate of the received data.
		let dataReceived = note.userInfo![NSFileHandleNotificationDataItem] as! Data
		delegate?.didReadFromStdout(self, data: dataReceived)

		// Resume reading from the pipe.
		processStdout.fileHandleForReading.readInBackgroundAndNotify()
	}

	@objc private func didReadFromProcessStderr(_ note: Notification) {
		// Inform the delegate of the received data.
		let dataReceived = note.userInfo![NSFileHandleNotificationDataItem] as! Data
		delegate?.didReadFromStderr(self, data: dataReceived)

		// Resume reading from the pipe.
		processStderr.fileHandleForReading.readInBackgroundAndNotify()
	}

	@objc private func processDidTerminate(_: Notification) {
		// Inform the delegate and perform cleanup.
		stopObserving()
		delegate?.didTerminate(self)
		process = nil
	}

	// MARK: - Private methods

	/// Start listening for notifications.
	private func startObserving() {
		assert(process != nil, "Process is not running.")
		if isObserving {
			return
		}
		let nc = NotificationCenter.default
		nc.addObserver(self,
		               selector: #selector(didReadFromProcessStdout(_:)),
		               name: FileHandle.readCompletionNotification,
		               object: processStdout.fileHandleForReading)
		nc.addObserver(self,
		               selector: #selector(didReadFromProcessStderr(_:)),
		               name: FileHandle.readCompletionNotification,
		               object: processStderr.fileHandleForReading)
		nc.addObserver(self,
		               selector: #selector(processDidTerminate(_:)),
		               name: Process.didTerminateNotification,
		               object: process)
		isObserving = true
	}

	/// Stop listening for notifications.
	private func stopObserving() {
		guard isObserving else {
			return
		}
		let nc = NotificationCenter.default
		nc.removeObserver(self,
		                  name: FileHandle.readCompletionNotification,
		                  object: processStdout.fileHandleForReading)
		nc.removeObserver(self,
		                  name: FileHandle.readCompletionNotification,
		                  object: processStderr.fileHandleForReading)
		nc.removeObserver(self,
		                  name: Process.didTerminateNotification,
		                  object: process)
		isObserving = false
	}
}
