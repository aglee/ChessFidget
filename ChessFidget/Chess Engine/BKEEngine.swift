//
//  ChessEngine.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/12/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

import Foundation

// <http://stackoverflow.com/questions/24034544/dispatch-after-gcd-in-swift/24318861#24318861>
func delay(_ delay:Double, closure:@escaping ()->()) {
	let when = DispatchTime.now() + delay
	DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}


/// Runs a chess engine in a subprocess (NSTask) and communicates with it via text commands and responses, using the "Chess Engine Communication Protocol" specified at <https://www.gnu.org/software/xboard/engine-intf.html>.
///
/// Commands for setting the strength of the engine:
///
/// - "sd DEPTH" specifies the max search depth the engine should go to.
/// - "st TIME" specifies the max time the engine should spend per move.  The protocol says "TIME" can be either a number of seconds or a string like 05:30.
/// - There is a "level" command for regulating time, with more sophisticated parameters.  The "level" command is not supported here.
@objc class BKEEngine: NSObject, PortDelegate {

	let MBCGameLoadNotification            = "MBCGameLoadNotification"
	let MBCGameStartNotification			= "MBCGameStartNotification"
	let MBCWhiteMoveNotification			= "MBCWhiteMoveNotification"
	let MBCBlackMoveNotification			= "MBCBlackMoveNotification"
	let MBCUncheckedWhiteMoveNotification  = "MBCUncheckedWhiteMoveNotification"
	let MBCUncheckedBlackMoveNotification	= "MBCUncheckedBlackMoveNotification"
	let MBCIllegalMoveNotification			= "MBCIllegalMoveNotification"
	let MBCEndMoveNotification				= "MBCEndMoveNotification"
	let MBCGameEndNotification				= "MBCGameEndNotification"

	// This comment is from the original Apple code:
	//
	// ---- snip ----
	// Paradoxically enough, moving as quickly as possible is
	// not necessarily desirable. Users tend to get frustrated
	// once they realize how little time their Mac really spends
	// to crush them at low levels. In the interest of promoting
	// harmonious Human - Machine relations, we enforce minimum
	// response times.
	// ---- snip ----
	//
	// I'm changing these values to zero, since for my purposes I don't want the artificial delay.
	let kInteractiveDelay: TimeInterval = 0.0  //2.0;
	let kAutomaticDelay: TimeInterval = 0.0  //4.0;

	var engineOwner: Any?

	var engineProcess = Process()
	var engineLaunchPath = "/Applications/Chess.app/Contents/Resources/sjeng.ChessEngine"

	var pipeToEngine = Pipe()
	var pipeFromEngine = Pipe()

	var fileHandleToEngine: FileHandle
	var fileHandleFromEngine: FileHandle

	var portForEngineMoves = Port()
	var portMessageWithMove: PortMessage

	var mainRunLoop = RunLoop.current

	var lastMove: BKEMove?
	var lastSide = BKESide.neitherSide
	var engineIsThinking = false
	var shouldWaitForStartCommand = true
	var positionIsSet = false
	var engineIsEnabled = false
	var needsGoCommand = false
	var engineSide = BKESide.neitherSide
	var dontMoveBefore = Date.timeIntervalSinceReferenceDate
	var isLogging = false {
		didSet {
			if isLogging && engineLogFileHandle != nil {
				let fileManager = FileManager.default
				var logDirPath: String?

				do {
					logDirPath = try fileManager.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("Logs").path

					guard let logDirPath = logDirPath else {
						return
					}

					try fileManager.createDirectory(atPath: logDirPath, withIntermediateDirectories: true, attributes: nil)

					//deprecated: [[NSDate date] descriptionWithCalendarFormat:@"Chess %Y-%m-%d %H%M" timeZone:nil locale:nil]
					let dateFormatter = DateFormatter()
					dateFormatter.setLocalizedDateFormatFromTemplate("Chess %Y-%m-%d %H%M")

					let dateString = dateFormatter.string(from: Date())
					let logFileName = "\(dateString) \(engineProcess.processIdentifier).log"
					let logFilePath = logDirPath.appending(logFileName)
					fileManager.createFile(atPath: logFilePath, contents: nil, attributes: nil)
					engineLogFileHandle = FileHandle(forWritingAtPath:logFilePath)
				} catch {
					print("ERROR: \(error)")
				}
			}
		}
	}
	var engineLogFileHandle: FileHandle?

	var hasObservers = false

	var maxSearchDepth = 4 {
		didSet {
			writeMaxSearchDepth(maxSearchDepth)
		}
	}

	var maxSecondsPerMove = 1 {
		didSet {
			writeMaxSecondsPerMove(maxSecondsPerMove)
		}
	}

	var shouldThinkWhileHumanIsThinking = false {
		didSet {
			writeEasyOrHard()
		}
	}

	var fSide: BKESide = .neitherSide

	override init() {
		engineProcess.standardInput = pipeToEngine
		engineProcess.standardOutput = pipeFromEngine
		engineProcess.launchPath = engineLaunchPath
		engineProcess.arguments = ["sjeng (Chess Engine)"]
		fileHandleToEngine = pipeToEngine.fileHandleForWriting
		fileHandleFromEngine = pipeFromEngine.fileHandleForReading
		portMessageWithMove = PortMessage(send: portForEngineMoves, receive: portForEngineMoves, components: [])

		// Call super.
		super.init()

		//
		enableEngineMoves(true)

		// Schedule the engine process to launch after a brief delay.
//		let delay: Double = 0.001
//		let when = DispatchTime.now() + delay
//		DispatchQueue.main.asyncAfter(deadline: when, execute: {
//			self.engineProcess.launch()
//		})
		engineProcess.perform(#selector(launch), with: nil, afterDelay: 0.001)

		// Set up to communicate with the engine.
		portForEngineMoves.setDelegate(self)

		// Spawn a thread to read data that the engine pipes out.
		Thread.detachNewThreadSelector(#selector(runEngine), toTarget: self, with: nil)

		// Tell the chess engine to validate the moves we send it.
		// TODO: I don't see "confirm_moves" documented as a command?
		writeToEngine("xboard\nconfirm_moves\n");
	}

	deinit {
		removeChessObservers()
		shutdown()
	}

	// MARK: - Starting games

	func startGame(sideToPlay: BKESide) {
		// Get rid of queued up move notifications
		enableEngineMoves(false)

		if engineProcess.isRunning {
			NSObject.cancelPreviousPerformRequests(withTarget: self)
		}

		if !positionIsSet {
			tellEngineToStartNewGame()
			lastSide = .blackSide
			needsGoCommand = false
		} else {
			needsGoCommand = (sideToPlay != .neitherSide)
			positionIsSet = false
		}

		removeChessObservers()

		let notificationCenter = NotificationCenter.default

		fSide = sideToPlay

		switch fSide {
		case .whiteSide:
			notificationCenter.addObserver(self, selector: #selector(opponentMoved), name: NSNotification.Name(MBCUncheckedBlackMoveNotification), object: engineOwner)
		case .bothSides:
			writeToEngine("go\n")
			engineIsThinking = true
		case .neitherSide:
			notificationCenter.addObserver(self, selector: #selector(opponentMoved), name: NSNotification.Name(MBCUncheckedWhiteMoveNotification), object: engineOwner)
			notificationCenter.addObserver(self, selector: #selector(opponentMoved), name: NSNotification.Name(MBCUncheckedBlackMoveNotification), object: engineOwner)
			writeToEngine("force\n")
			engineIsThinking = false;
		default:
			// Engine plays black
			notificationCenter.addObserver(self, selector: #selector(opponentMoved), name: NSNotification.Name(MBCUncheckedWhiteMoveNotification), object: engineOwner)
		}

		if (fSide == .whiteSide || fSide == .blackSide) {
			engineIsThinking = (fSide != lastSide)
			if engineIsThinking {
				needsGoCommand = false
				writeToEngine("go\n")
			}
		}

		notificationCenter.addObserver(self, selector: #selector(moveDone), name: NSNotification.Name(MBCEndMoveNotification), object: engineOwner)
		hasObservers = true
		shouldWaitForStartCommand = true  // Suppress further moves until start
		enableEngineMoves(true)
	}

//	- (void)startGameWithFEN:(NSString *)fen holding:(NSString *)holding moves:(NSString *)moves
//	{
//		[self tellEngineToStartNewGame];
//
//		fSetPosition = true;
//		fLastMove = nil;
//
//		const char *s = [fen UTF8String];
//		while (isspace(*s)) {
//			++s;
//		}
//		while (!isspace(*s)) {
//			++s;
//		}
//		while (isspace(*s)) {
//			++s;
//		}
//		fLastSide = (*s == 'w' ? kBlackSide : kWhiteSide);
//
//		if (moves) {
//			[self writeToEngine:@"force\n"];
//			[self writeToEngine:moves];
//		} else {
//			if (*s == 'b') {
//				[self writeToEngine:@"black\n"];
//			}
//			[self writeToEngine:[NSString stringWithFormat:@"setboard %@\n", fen]];
//		}
//	}

	// MARK: - PortDelegate methods

	func handle(_ message: PortMessage) {
		let move = BKEMove(compactMove: Int(message.msgid))

		if shouldWaitForStartCommand {  // Suppress all commands until next start
			if move.command == .kCmdStartGame {
				shouldWaitForStartCommand = false
			}
			return
		}


		// Otherwise, handle move confirmations or rejections here and
		// broadcast the rest of the moves
		switch move.command {
		case .kCmdUndo:
			// Last unchecked move was rejected
			engineIsThinking = false
			NotificationCenter.default.post(name: NSNotification.Name(MBCIllegalMoveNotification),
			                                object: engineOwner,
			                                userInfo: ["move": move])
		case .kCmdMoveOK:
			if lastMove != nil { // Ignore confirmations of game setup moves
				flipSide()
				// Suspend processing until move performed on board
				enableEngineMoves(false)
				NotificationCenter.default.post(name: NSNotification.Name(notificationForSide()), object: engineOwner, userInfo: ["move": move])
				if needsGoCommand {
					needsGoCommand = false
					writeToEngine("go\n")
				}
			}
		case .kCmdPMove, .kCmdPDrop: break
		case .kCmdWhiteWins, .kCmdBlackWins, .kCmdDraw:
			NotificationCenter.default.post(name: NSNotification.Name(MBCGameEndNotification), object: engineOwner, userInfo: ["move": move])
		default:
			if fSide == .bothSides {
				writeToEngine("go\n")  // Trigger next move
			} else {
				engineIsThinking = false;
			}

			// After the engine moved, we defer further moves until the
			// current move is executed on the board
			enableEngineMoves(false)
			DispatchQueue.main.asyncAfter(deadline: DispatchTime(dontMoveBefore), execute: {
				self.executeMove(move: move)
			})

			if fSide == .bothSides {
				dontMoveBefore = max(Date.timeIntervalSinceReferenceDate, dontMoveBefore) + kAutomaticDelay
			}
		}
	}

	// MARK: - Private methods - misc

	private func enableEngineMoves(_ enable: Bool) {
		if enable != engineIsEnabled {
			engineIsEnabled = enable;
			if (engineIsEnabled) {
				mainRunLoop.add(portForEngineMoves, forMode: RunLoopMode.defaultRunLoopMode)
			} else {
				mainRunLoop.remove(portForEngineMoves, forMode: RunLoopMode.defaultRunLoopMode)
			}
		}
	}

	private func executeMove(move: BKEMove) {
		flipSide()
		NotificationCenter.default.post(	name: Notification.Name(notificationForSide()),
		                                	object: engineOwner,
		                                	userInfo: ["move": move])
	}

	private func flipSide() {
		lastSide = (lastSide == .blackSide) ? .whiteSide : .blackSide
	}

	private let BKEWhiteMoveNotification = "BKEWhiteMoveNotification"
	private let BKEBlackMoveNotification = "BKEBlackMoveNotification"

	private func notificationForSide() -> String {
		return (lastSide == .whiteSide ? BKEWhiteMoveNotification : BKEBlackMoveNotification)
	}

	private func squareToCoord(_ square: BKESquare) -> String {
		let rowChars = ["1", "2", "3", "4", "5", "6", "7", "8"]
		let colChars = ["a", "b", "c", "d", "e", "f", "g", "h"]
		return "\(colChars[square % 8])\(rowChars[square / 8])"
	}

	// MARK: - Private methods - engine startup and teardown

	@objc private func runEngine() {
//		@autoreleasepool {
//			[[NSThread currentThread] threadDictionary][@"InputHandle"] = fFromEngine;
//			[[NSThread currentThread] threadDictionary][@"Engine"] = self;
//
//			MBCLexerInstance scanner;
//			MBCLexerInit(&scanner);
//			while (unsigned cmd = MBCLexerScan(scanner)) {
//				[fMove setMsgid:cmd];
//				[fMove sendBeforeDate:[NSDate distantFuture]];
//	//			[pool release];
//	//			pool  = [[NSAutoreleasePool alloc] init];
//			}
//			MBCLexerDestroy(scanner);
//		}
	}

	private func removeChessObservers() {
		if hasObservers {
			return
		}

		let notificationCenter = NotificationCenter.default
		notificationCenter.removeObserver(self, name: NSNotification.Name(MBCUncheckedWhiteMoveNotification), object: nil)
		notificationCenter.removeObserver(self, name: NSNotification.Name(MBCUncheckedBlackMoveNotification), object: nil)
		notificationCenter.removeObserver(self, name: NSNotification.Name(MBCEndMoveNotification), object: nil)

		hasObservers = false
	}
	
	private func shutdown() {
		engineOwner = nil;
		enableEngineMoves(false)
		if engineProcess.isRunning {
			engineProcess.terminate()
		}
	}

	// MARK: - Private methods - engine logging

	private func logToEngine(_ text: String) {
		if isLogging {
			writeLog(">>> \(text.components(separatedBy: "\n").joined(separator: "\n>>> "))\n")
		}
	}

	private func logFromEngine(_ text: String) {
		if isLogging {
			writeLog(text)
		}
	}

	private func writeLog(_ text: String) {
		engineLogFileHandle?.write(text.data(using: .ascii)!)
	}

	// MARK: - Private methods - talking to the chess engine process

	private func tellEngineToStartNewGame() {
		writeToEngine("?new\n")
		writeMaxSearchDepth(maxSearchDepth)
		writeMaxSecondsPerMove(maxSecondsPerMove)
		writeEasyOrHard()
	}

	private func writeToEngine(_ string: String) {
		if let data = string.data(using: String.Encoding.ascii) {
			fileHandleToEngine.write(data)
		}
	}

	private func writeMaxSearchDepth(_ depth: Int) {
		writeToEngine("sd \(depth)\n")
	}

	private func writeMaxSecondsPerMove(_ seconds: Int) {
		writeToEngine("st \(seconds)\n")
	}

	private func writeEasyOrHard() {
		writeToEngine(shouldThinkWhileHumanIsThinking ? "hard\n" : "easy\n")
	}
	
	// MARK: - Private methods - notification handlers

	@objc private func moveDone(_: Notification) {
		enableEngineMoves(true)
	}

	@objc private func opponentMoved(_ notif: Notification) {
//		// Got a human move, ask engine to verify it
//		const char *piece = " KQBNRP  kqbnrp ";
//		MBCMove *move = reinterpret_cast<MBCMove *>([notification userInfo]);
//
//		fLastMove = move;
//
//		switch (move->fCommand) {
//			case kCmdMove:
//				if (move->fPromotion) {
//					[self writeToEngine:[NSString stringWithFormat:@"%@%@%c\n",
//										 [self squareToCoord:move->fFromSquare],
//										 [self squareToCoord:move->fToSquare],
//										 piece[move->fPromotion]]];
//				} else {
//					[self writeToEngine:[NSString stringWithFormat:@"%@%@\n",
//										 [self squareToCoord:move->fFromSquare],
//										 [self squareToCoord:move->fToSquare]]];
//				}
//				fThinking = fSide != kNeitherSide;
//				break;
//			case kCmdDrop:
//				[self writeToEngine:[NSString stringWithFormat:@"%c@%@\n",
//									 piece[move->fPiece],
//									 [self squareToCoord:move->fToSquare]]];
//				fThinking = fSide != kNeitherSide;
//				break;
//			default:
//				break;
//		}
//
//		fDontMoveBefore	= [NSDate timeIntervalSinceReferenceDate]+kInteractiveDelay;
	}

}

