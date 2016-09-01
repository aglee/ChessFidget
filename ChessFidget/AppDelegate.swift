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

	// MARK: - Action methods

	@IBAction func newDocument(_ sender: AnyObject?) {
		let wc = GameWindowController(game: Game())
		print("newDocument \(wc)")
		gameWindowControllers.append(wc)
		if gameWindowControllers.count == 1 {
			wc.window?.center()
		}
		wc.showWindow(nil)
	}

	// TODO: Remove window controller when window closes.  Or better yet, convert this to document-based app.

	// MARK: - NSApplicationDelegate methods

	func applicationDidFinishLaunching(_ aNotification: Notification) {



		newDocument(nil)
	}

	func applicationWillTerminate(_ aNotification: Notification) {
	}

	// MARK: - Private methods



}

