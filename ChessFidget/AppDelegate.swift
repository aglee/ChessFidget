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

	var gameWindowControllers: [GameWindowController] = []

	// MARK: - NSApplicationDelegate methods

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		newGameWindow()
	}

	// MARK: - Private methods

	private func newGameWindow() {
		// TODO: Remove window controller when window closes.  Or maybe convert this to a document-based app so that will be handled automatically.
		let wc = GameWindowController(game: Game(humanPlayerPieceColor: .White))
		gameWindowControllers.append(wc)
		if gameWindowControllers.count == 1 {
			wc.window?.center()
		}
		wc.showWindow(nil)
	}

}

