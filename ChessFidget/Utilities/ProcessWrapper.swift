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
	var isRunning: Bool { process?.isRunning ?? false }

	private var process: Process? = nil {
		willSet {
			guard let p = process else { return }
			let nc = NotificationCenter.default
			if let stdout = p.standardOutput as? Pipe {
				nc.removeObserver(self,
								  name: FileHandle.readCompletionNotification,
								  object: stdout.fileHandleForReading)
			}
			if let stderr = p.standardError as? Pipe {
				nc.removeObserver(self,
								  name: FileHandle.readCompletionNotification,
								  object: stderr.fileHandleForReading)
			}
			nc.removeObserver(self, name: Process.didTerminateNotification, object: p)
		}
		didSet {
			guard let p = process else { return }
			let nc = NotificationCenter.default
			if let stdout = p.standardOutput as? Pipe {
				nc.addObserver(self,
							   selector: #selector(didReadFromProcessStdout(_:)),
							   name: FileHandle.readCompletionNotification,
							   object: stdout.fileHandleForReading)
			}
			if let stderr = p.standardError as? Pipe {
				nc.addObserver(self,
							   selector: #selector(didReadFromProcessStderr(_:)),
							   name: FileHandle.readCompletionNotification,
							   object: stderr.fileHandleForReading)
			}
			nc.addObserver(self,
						   selector: #selector(processDidTerminate(_:)),
						   name: Process.didTerminateNotification,
						   object: p)
		}
	}
	
	// MARK: - Init/deinit

	init(launchPath: String, arguments: [String]) {
		self.launchPath = launchPath
		self.arguments = arguments
	}

	deinit {
		print(";;; ProcessWrapper deinit -- \((launchPath as NSString).lastPathComponent)")
		process?.terminate()
		process = nil
	}

	// MARK: - Interacting with the process

	func launchProcess() {
		if process != nil {
			print(";;; Process is already running.")
			return
		}

		// Create a Process object.  Note that the `didSet` for our `process` property
		// relies on the various pipes having been set up.
		let p = Process()
		p.launchPath = launchPath
		p.arguments = arguments
		let inputPipe = Pipe()
		let outputPipe = Pipe()
		let errorPipe = Pipe()
		p.standardInput = inputPipe
		p.standardOutput = outputPipe
		p.standardError = errorPipe
		process = p

		// Launch the process.
		inputPipe.fileHandleForWriting.readInBackgroundAndNotify()
		outputPipe.fileHandleForReading.readInBackgroundAndNotify()
		errorPipe.fileHandleForReading.readInBackgroundAndNotify()
		p.launch()
	}

	/// Sends data to the process's standard input.
	func writeToProcess(_ data: Data) {
		guard data.count > 0 else { return }
		guard let p = process else {
			return print(";;; [ERROR] Process is not running, cannot send data to it.")
		}
		guard p.isRunning else {
			return print(";;; [ERROR] Process has been terminated, cannot send data to it.")
		}
		guard let stdinPipe = p.standardInput as? Pipe else {
			return print(";;; [ERROR] Process is expected to have a pipe for stdin.")
		}
		stdinPipe.fileHandleForWriting.write(data)
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

	@objc private func didReadFromProcessStdout(_ notif: Notification) {
		guard let stdout = notif.object as? FileHandle else {
			return print(";;; [ERROR] Expected a FileHandle as the stdout notification object.")
		}
		
		// Inform the delegate of the received data.
		let dataReceived = notif.userInfo![NSFileHandleNotificationDataItem] as! Data
		delegate?.didReadFromStdout(self, data: dataReceived)

		// Resume reading from the pipe.
		stdout.readInBackgroundAndNotify()
	}

	@objc private func didReadFromProcessStderr(_ notif: Notification) {
		guard let stderr = notif.object as? FileHandle else {
			return print(";;; [ERROR] Expected a FileHandle as the stderr notification object.")
		}
		
		// Inform the delegate of the received data.
		let dataReceived = notif.userInfo![NSFileHandleNotificationDataItem] as! Data
		delegate?.didReadFromStderr(self, data: dataReceived)

		// Resume reading from the pipe.
		stderr.readInBackgroundAndNotify()
	}

	@objc private func processDidTerminate(_: Notification) {
		// Inform the delegate and perform cleanup.
		delegate?.didTerminate(self)
		process = nil
	}

}
