//
//  ProcessWrapper.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/13/17.
//  Copyright © 2017 Andy Lee. All rights reserved.
//

import Foundation

class ProcessWrapper {
	weak var delegate: (AnyObject & ProcessWrapperDelegate)?
	let launchPath: String
	let arguments: [String]

	var isRunning: Bool {
		if let p = self.process {
			return p.isRunning
		} else {
			return false
		}
	}

	private var process: Process? = nil
	private var isObserving: Bool = false

	private var processStdin: Pipe { return self.process?.standardInput as! Pipe }
	private var processStdout: Pipe { return self.process?.standardOutput as! Pipe }
	private var processStderr: Pipe { return self.process?.standardError as! Pipe }

	// MARK: - Init/deinit

	init(launchPath: String, arguments: [String]) {
		self.launchPath = launchPath
		self.arguments = arguments
	}

	deinit {
		self.stopObserving()
		self.process?.terminate()
	}

	// MARK: - Interacting with the process

	func launchProcess() {
		if let _ = self.process {
			print("Task is already running.")
			return;
		}

		let p = Process()
		p.launchPath = self.launchPath
		p.arguments = self.arguments
		self.process = p

		let inputPipe = Pipe()
		let outputPipe = Pipe()
		let errorPipe = Pipe()
		p.standardInput = inputPipe
		p.standardOutput = outputPipe
		p.standardError = errorPipe
		self.startObserving()
		inputPipe.fileHandleForWriting.readInBackgroundAndNotify()
		outputPipe.fileHandleForReading.readInBackgroundAndNotify()
		outputPipe.fileHandleForReading.readInBackgroundAndNotify()

		p.launch()
	}

	func writeToProcess(_ data: Data) {
		guard let p = self.process else {
			print("+++ [ERROR] Task is not running, cannot send data to it.")
			return
		}
		guard p.isRunning else {
			print("+++ [ERROR] Task has been terminated, cannot send data to it.")
			return;
		}
		self.processStdin.fileHandleForWriting.write(data)
	}

	// Convenience method that calls writeToProcess(_ data:).  Uses UTF-8.
	func writeToProcess(_ string: String) {
		if let d = string.data(using: String.Encoding.utf8) {
			self.writeToProcess(d)
		}
	}

	func terminateProcess() {
		self.process?.terminate()
		self.process = nil
	}

	// MARK: - Notification handlers

	// Inform the delegate of the received data.  Resume reading from the pipe.
	@objc private func didReadFromProcessStdout(_ note: Notification) {
		let dataReceived = note.userInfo![NSFileHandleNotificationDataItem] as! Data
		self.delegate?.didReadFromStdout(self, data: dataReceived)
		self.processStdout.fileHandleForReading.readInBackgroundAndNotify()
	}

	// Inform the delegate of the received data.  Resume reading from the pipe.
	@objc private func didReadFromProcessStderr(_ note: Notification) {
		let dataReceived = note.userInfo![NSFileHandleNotificationDataItem] as! Data
		self.delegate?.didReadFromStderr(self, data: dataReceived)
		self.processStderr.fileHandleForReading.readInBackgroundAndNotify()
	}

	// Inform the delegate and perform cleanup.
	@objc private func processDidTerminate(_ note: Notification) {
		self.stopObserving()
		self.delegate?.didTerminate(self)
		self.process = nil;
	}

	// MARK: - Private methods

	// Start listening for notifications.
	func startObserving() {
		assert(self.process != nil, "Process is not running.")
		if self.isObserving {
			return;
		}
		let nc = NotificationCenter.default
		nc.addObserver(self,
		               selector: #selector(didReadFromProcessStdout(_:)),
		               name: FileHandle.readCompletionNotification,
		               object: self.processStdout.fileHandleForReading)
		nc.addObserver(self,
		               selector: #selector(didReadFromProcessStderr(_:)),
		               name: FileHandle.readCompletionNotification,
		               object: self.processStderr.fileHandleForReading)
		nc.addObserver(self,
		               selector: #selector(processDidTerminate(_:)),
		               name: Process.didTerminateNotification,
		               object: self.process)
		self.isObserving = true;
	}

	func stopObserving() {
		guard self.isObserving else {
			return;
		}
		let nc = NotificationCenter.default
		nc.removeObserver(self,
		                  name: FileHandle.readCompletionNotification,
		                  object: self.processStdout.fileHandleForReading)
		nc.removeObserver(self,
		                  name: FileHandle.readCompletionNotification,
		                  object: self.processStderr.fileHandleForReading)
		nc.removeObserver(self,
		                  name: Process.didTerminateNotification,
		                  object: self.process)
		self.isObserving = false;
	}
}