/*
	File:		MBCEngine.mm
	Contains:	An agent representing the sjeng chess engine
	Copyright:	© 2002-2011 by Apple Inc., all rights reserved.
 */

#import "MBCEngine.h"
#import "MBCEngineCommands.h"

#include <unistd.h>
#include <algorithm>

NSString * const MBCGameLoadNotification            = @"MBCGameLoadNotification";
NSString * const MBCGameStartNotification			= @"MBCGameStartNotification";
NSString * const MBCWhiteMoveNotification			= @"MBCWhiteMoveNotification";
NSString * const MBCBlackMoveNotification			= @"MBCBlackMoveNotification";
NSString * const MBCUncheckedWhiteMoveNotification  = @"MBCUncheckedWhiteMoveNotification";
NSString * const MBCUncheckedBlackMoveNotification	= @"MBCUncheckedBlackMoveNotification";
NSString * const MBCIllegalMoveNotification			= @"MBCIllegalMoveNotification";
NSString * const MBCEndMoveNotification				= @"MBCEndMoveNotification";
NSString * const MBCGameEndNotification				= @"MBCGameEndNotification";

NSString * const kMBCHumanPlayer					= @"human";
NSString * const kMBCEnginePlayer					= @"program";

//
// Paradoxically enough, moving as quickly as possible is
// not necessarily desirable. Users tend to get frustrated
// once they realize how little time their Mac really spends
// to crush them at low levels. In the interest of promoting
// harmonious Human - Machine relations, we enforce minimum
// response times.
//
const NSTimeInterval kInteractiveDelay	= 2.0;
const NSTimeInterval kAutomaticDelay	= 4.0;

using std::max;

@implementation MBCEngine

@synthesize fSide = fSide;

#pragma mark - Init/awake/dealloc

- (id) init
{
	self = [super init];
	if (self == nil) {
		return nil;
	}

	fEngineEnabled = false;
	fSetPosition	 = false;
	fNeedsGo = false;
	fLastMove = nil;
	fDontMoveBefore	= [NSDate timeIntervalSinceReferenceDate];
	fMainRunLoop = [NSRunLoop currentRunLoop];
	fEngineMoves = [NSPort port];
	[fEngineMoves setDelegate:self];
	fMove = [[NSPortMessage alloc] initWithSendPort:fEngineMoves
										receivePort:fEngineMoves
										 components:@[]];
	[self enableEngineMoves:YES];
	fEngineTask 	= [[NSTask alloc] init];
	fToEnginePipe = [[NSPipe alloc] init];
	fFromEnginePipe = [[NSPipe alloc] init];
	[fEngineTask setStandardInput:fToEnginePipe];
	[fEngineTask setStandardOutput:fFromEnginePipe];
	[fEngineTask setLaunchPath:[self pathToSjengExecutable]];
	[fEngineTask setArguments: @[@"sjeng (Chess Engine)"]];
	[self performSelector:@selector(launchEngine:) withObject:nil afterDelay:0.001];
	fToEngine = [fToEnginePipe fileHandleForWriting];
	fFromEngine = [fFromEnginePipe fileHandleForReading];
	[NSThread detachNewThreadSelector:@selector(runEngine:) toTarget:self withObject:nil];
	[self writeToEngine:@"xboard\nconfirm_moves\n"];

	return self;
}

- (void)dealloc
{
	[self removeChessObservers];
	[self shutdown];
}

#pragma mark - Getters and setters

- (NSString *)pathToSjengExecutable
{
	//[agl]	return [[NSBundle mainBundle] pathForResource:@"sjeng" ofType:@"ChessEngine"];
	return @"/Applications/Chess.app/Contents/Resources/sjeng.ChessEngine";
}

- (BOOL)isLogging
{
	return fIsLogging;
}

- (void)setLogging:(BOOL)logging
{
	fIsLogging = logging;
	if (fIsLogging && !fEngineLogFile) {
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSURL *libLog = [[fileManager URLForDirectory:NSLibraryDirectory
											 inDomain:NSUserDomainMask
									appropriateForURL:nil
											   create:YES
												error:nil] URLByAppendingPathComponent:@"Logs"];
		NSString *logDirPath = [libLog path];
		[fileManager createDirectoryAtPath:logDirPath
			   withIntermediateDirectories:YES
								attributes:nil
									 error:nil];
		//deprecated: [[NSDate date] descriptionWithCalendarFormat:@"Chess %Y-%m-%d %H%M" timeZone:nil locale:nil]
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setLocalizedDateFormatFromTemplate:@"Chess %Y-%m-%d %H%M"];
		NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
		NSString *logFileName = [NSString stringWithFormat:@"%@ %d.log",
								 dateString,
								 [fEngineTask processIdentifier]];
		NSString *logFilePath = [logDirPath stringByAppendingPathComponent:logFileName];
		creat([logFilePath fileSystemRepresentation], 0666);
		fEngineLogFile = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
	}
}

- (void)setSearchTime:(int)time
{
	if (time < 0) {
		[self writeToEngine:[NSString stringWithFormat:@"sd %d\n", 4+time]];
	} else {
		[self writeToEngine:[NSString stringWithFormat:@"sd 40\nst %d\n",
							 [MBCEngine secondsForTime:time]]];
	}
}

#pragma mark - Time conversion

+ (int)secondsForTime:(int)time
{
	return (int)lround(ldexpf(1.0f, time));
}

#pragma mark - Starting games

- (void)startGameWithSideToPlay:(MBCSide)sideToPlay
{
	// Get rid of queued up move notifications
	[self enableEngineMoves:NO];

	if ([fEngineTask isRunning]) {
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
	}

	if (!fSetPosition) {
		[self tellEngineToStartNewGame];
		fLastSide = kBlackSide;
		fNeedsGo = false;
	} else {
		fNeedsGo = sideToPlay != kNeitherSide;
		fSetPosition = false;
	}

	[self removeChessObservers];
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

	switch (fSide = sideToPlay) {
		case kWhiteSide:
			[notificationCenter addObserver:self selector:@selector(opponentMoved:) name:MBCUncheckedBlackMoveNotification object:self.engineOwner];
			break;
		case kBothSides:
			[self writeToEngine:@"go\n"];
			fThinking = true;
			break;
		case kNeitherSide:
			[notificationCenter addObserver:self selector:@selector(opponentMoved:) name:MBCUncheckedWhiteMoveNotification object:self.engineOwner];
			[notificationCenter addObserver:self selector:@selector(opponentMoved:) name:MBCUncheckedBlackMoveNotification object:self.engineOwner];
			[self writeToEngine:@"force\n"];
			fThinking = false;
			break;
		default:
			// Engine plays black
			[notificationCenter addObserver:self selector:@selector(opponentMoved:) name:MBCUncheckedWhiteMoveNotification object:self.engineOwner];
			break;
	}
	if (fSide == kWhiteSide || fSide == kBlackSide) {
		if ((fThinking = (fSide != fLastSide))) {
			fNeedsGo = false;
			[self writeToEngine:@"go\n"];
		}
	}

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveDone:) name:MBCEndMoveNotification object:self.engineOwner];
	fHasObservers = YES;
	fWaitForStart = true;	// Suppress further moves until start
	[self enableEngineMoves:YES];
}

- (void)startGameWithFEN:(NSString *)fen holding:(NSString *)holding moves:(NSString *)moves
{
	[self tellEngineToStartNewGame];

	fSetPosition = true;
	fLastMove = nil;

	const char *s = [fen UTF8String];
	while (isspace(*s)) {
		++s;
	}
	while (!isspace(*s)) {
		++s;
	}
	while (isspace(*s)) {
		++s;
	}
	fLastSide = (*s == 'w' ? kBlackSide : kWhiteSide);

	if (moves) {
		[self writeToEngine:@"force\n"];
		[self writeToEngine:moves];
	} else {
		if (*s == 'b') {
			[self writeToEngine:@"black\n"];
		}
		[self writeToEngine:[NSString stringWithFormat:@"setboard %@\n", fen]];
	}
}

#pragma mark - <NSPortDelegate> methods

- (void)handlePortMessage:(NSPortMessage *)message
{
	MBCMove	*move = [MBCMove moveFromCompactMove:[message msgid]];

	if (fWaitForStart) { // Suppress all commands until next start
		if (move->fCommand == kCmdStartGame) {
			fWaitForStart = false;
		}
		return;
	}

	// Otherwise, handle move confirmations or rejections here and
	// broadcast the rest of the moves
	switch (move->fCommand) {
		case kCmdUndo:
			// Last unchecked move was rejected
			fThinking = false;
			[[NSNotificationCenter defaultCenter] postNotificationName:MBCIllegalMoveNotification object:self.engineOwner userInfo:(id)move];
			break;
		case kCmdMoveOK:
			if (fLastMove) { // Ignore confirmations of game setup moves
				[self flipSide];
				// Suspend processing until move performed on board
				[self enableEngineMoves:NO];
				[[NSNotificationCenter defaultCenter] postNotificationName:[self notificationForSide] object:self.engineOwner userInfo:(id)fLastMove];
				if (fNeedsGo) {
					fNeedsGo = false;
					[self writeToEngine:@"go\n"];
				}
			}
			break;
		case kCmdPMove:
		case kCmdPDrop:
			break;
		case kCmdWhiteWins:
		case kCmdBlackWins:
		case kCmdDraw:
			[[NSNotificationCenter defaultCenter] postNotificationName:MBCGameEndNotification object:self.engineOwner userInfo:(id)move];
			break;
		default:
			if (fSide == kBothSides) {
				[self writeToEngine:@"go\n"]; // Trigger next move
			} else {
				fThinking = false;
			}

			// After the engine moved, we defer further moves until the
			// current move is executed on the board
			[self enableEngineMoves:NO];

			NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
			[self performSelector:@selector(executeMove:)
					   withObject:move
					   afterDelay:(fDontMoveBefore - now)];

			if (fSide == kBothSides) {
				fDontMoveBefore = max(now,fDontMoveBefore)+kAutomaticDelay;
			}

			break;
	}
}

#pragma mark - Private methods - misc

- (void)enableEngineMoves:(BOOL)enable
{
	if (enable != fEngineEnabled) {
		fEngineEnabled = enable;
		if (fEngineEnabled) {
			[fMainRunLoop addPort:fEngineMoves forMode:NSDefaultRunLoopMode];
		} else {
			[fMainRunLoop removePort:fEngineMoves forMode:NSDefaultRunLoopMode];
		}
	}
}

- (void)executeMove:(MBCMove *)move;
{
	[self flipSide];
	[[NSNotificationCenter defaultCenter] postNotificationName:[self notificationForSide] object:self.engineOwner userInfo:(id)move];
}

- (void)flipSide
{
	fLastSide = (fLastSide == kBlackSide) ? kWhiteSide : kBlackSide;
}

- (NSString *)notificationForSide
{
	return (fLastSide == kWhiteSide
			? MBCWhiteMoveNotification
			: MBCBlackMoveNotification);
}

- (NSString *)squareToCoord:(MBCSquare)square
{
	static const char *row = "12345678";
	static const char *col = "abcdefgh";

	return [NSString stringWithFormat:@"%c%c", col[square % 8], row[square / 8]];
}

#pragma mark - Private methods - engine startup and teardown

- (void)launchEngine:(id)arg
{
	[fEngineTask launch];
}

- (void)runEngine:(id)sender
{
	@autoreleasepool {
		[[NSThread currentThread] threadDictionary][@"InputHandle"] = fFromEngine;
		[[NSThread currentThread] threadDictionary][@"Engine"] = self;

		MBCLexerInstance scanner;
		MBCLexerInit(&scanner);
		while (unsigned cmd = MBCLexerScan(scanner)) {
			[fMove setMsgid:cmd];
			[fMove sendBeforeDate:[NSDate distantFuture]];
//			[pool release];
//			pool  = [[NSAutoreleasePool alloc] init];
		}
		MBCLexerDestroy(scanner);
	}
}

- (void)removeChessObservers
{
	if (!fHasObservers) {
		return;
	}

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self name:MBCUncheckedBlackMoveNotification object:nil];
	[notificationCenter removeObserver:self name:MBCUncheckedWhiteMoveNotification object:nil];
	[notificationCenter removeObserver:self name:MBCEndMoveNotification object:nil];

	fHasObservers = NO;
}

- (void)shutdown
{
	self.engineOwner = nil;
	[self enableEngineMoves:NO];
	if ([fEngineTask isRunning]) {
		[fEngineTask terminate];
	}
}

#pragma mark - Private methods - engine logging

- (void)logToEngine:(NSString *)text
{
	if (fIsLogging) {
		NSString *decorated = [NSString stringWithFormat:@">>> %@\n",
							   [[text componentsSeparatedByString:@"\n"]
								componentsJoinedByString:@"\n>>> "]];
		[self writeLog:decorated];
	}
}

- (void)logFromEngine:(NSString *)text
{
	if (fIsLogging) {
		[self writeLog:text];
	}
}

- (void)writeLog:(NSString *)text
{
	[fEngineLogFile writeData:[text dataUsingEncoding:NSASCIIStringEncoding]];
}

#pragma mark - Private methods - talking to the sjeng process

- (void)tellEngineToStartNewGame
{
	[self writeToEngine:@"?new\n"];
}

- (void)writeToEngine:(NSString *)string
{
	NSData *data = [string dataUsingEncoding:NSASCIIStringEncoding];
	[self logToEngine:string];
	[fToEngine writeData:data];
}

#pragma mark - Private methods - notification handlers

- (void)moveDone:(NSNotification *)notification
{
	[self enableEngineMoves:YES];
}

- (void)opponentMoved:(NSNotification *)notification
{
	// Got a human move, ask engine to verify it
	const char *piece = " KQBNRP  kqbnrp ";
	MBCMove *move = reinterpret_cast<MBCMove *>([notification userInfo]);

	fLastMove = move;

	switch (move->fCommand) {
		case kCmdMove:
			if (move->fPromotion) {
				[self writeToEngine:[NSString stringWithFormat:@"%@%@%c\n",
									 [self squareToCoord:move->fFromSquare],
									 [self squareToCoord:move->fToSquare],
									 piece[move->fPromotion]]];
			} else {
				[self writeToEngine:[NSString stringWithFormat:@"%@%@\n",
									 [self squareToCoord:move->fFromSquare],
									 [self squareToCoord:move->fToSquare]]];
			}
			fThinking = fSide != kNeitherSide;
			break;
		case kCmdDrop:
			[self writeToEngine:[NSString stringWithFormat:@"%c@%@\n",
								 piece[move->fPiece],
								 [self squareToCoord:move->fToSquare]]];
			fThinking = fSide != kNeitherSide;
			break;
		default:
			break;
	}

	fDontMoveBefore	= [NSDate timeIntervalSinceReferenceDate]+kInteractiveDelay;
}

@end


#pragma mark - Functions

void MBCIgnoredText(const char *text)
{
	// fprintf(stderr, "* %s", text);
}

int MBCReadInput(char *buf, int max_size)
{
	NSFileHandle *f = [[NSThread currentThread] threadDictionary][@"InputHandle"];
	MBCEngine *e = [[NSThread currentThread] threadDictionary][@"Engine"];

	ssize_t sz = read([f fileDescriptor], buf, max_size);
	if (sz > 0) {
		[e logFromEngine:[NSString stringWithFormat:@"%.*s", sz, buf]];
	}
	return sz;
}

