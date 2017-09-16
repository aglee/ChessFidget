//
//  AppDelegate.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/24/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	var gameWC: GameWindowController!

	// MARK: - NSApplicationDelegate protocol

	func applicationDidFinishLaunching(_: Notification) {
		self.chdirToAppSupportDirectory()

		self.gameWC = GameWindowController(game: Game(humanPlays: .white,
		                                              computerPlaysRandomly: true))
		self.gameWC.window?.center()
		self.gameWC.showWindow(nil)
	}

	// MARK: - Private methods

	/// Change the working directory to a subdirectory of Application Support.
	/// The .lrn files created by sjeng will go there instead of cluttering
	/// whatever directory we would otherwise be in by default.
	private func chdirToAppSupportDirectory() {
		let fm = FileManager.default

		// Locate the user's Application Support directory.
		guard let appSupportURL = fm.urls(for: .applicationSupportDirectory,
		                                  in: .userDomainMask).first else {
			print("ERROR: Could not locate Application Support directory")
			return
		}

		// Create the app-specific subdirectory if it doesn't exist.
		let bundleID = Bundle.main.bundleIdentifier!
		let appSpecificURL = appSupportURL.appendingPathComponent(bundleID)
		do {
			try fm.createDirectory(at: appSpecificURL,
			                       withIntermediateDirectories: true,
			                       attributes: nil)
		} catch {
			print("ERROR: Could not create directory \(appSpecificURL)")
			return
		}
		
		// Make that the working directory.
		if !fm.changeCurrentDirectoryPath(appSpecificURL.path) {
			print("ERROR: Could not change working directory to '\(appSpecificURL.path)'")
		}
	}
}
