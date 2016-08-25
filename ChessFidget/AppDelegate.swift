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

	//@IBOutlet weak var window: NSWindow!
	var gameWindowController: GameWindowController!

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		gameWindowController = GameWindowController(windowNibName: "GameWindowController")
		gameWindowController.game = Game()


		// FIXME: set game properly
		let _ = gameWindowController.window
		gameWindowController.boardViewController.game = gameWindowController.game
		gameWindowController.boardViewController.boardView.game = gameWindowController.game

		gameWindowController.window!.center()
		gameWindowController.showWindow(nil)
	}

	func applicationWillTerminate(_ aNotification: Notification) {
	}

}

