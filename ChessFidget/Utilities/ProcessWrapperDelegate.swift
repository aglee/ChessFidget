//
//  ProcessWrapperDelegate.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/13/17.
//  Copyright © 2017 Andy Lee. All rights reserved.
//

import Foundation

/// Delegate used by the `ProcessWrapper` class.
protocol ProcessWrapperDelegate {
	func didReadFromStdout(_ processWrapper: ProcessWrapper, data: Data)
	func didReadFromStderr(_ processWrapper: ProcessWrapper, data: Data)
	func didTerminate(_ processWrapper: ProcessWrapper)
}
