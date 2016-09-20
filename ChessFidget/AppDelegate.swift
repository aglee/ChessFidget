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

	// MARK: - NSApplicationDelegate methods

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		gameWC = GameWindowController(game: Game(humanPlayerPieceColor: .White, computerPlaysRandomly: true))
		gameWC.window?.center()
		gameWC.showWindow(nil)
	}
	
}
