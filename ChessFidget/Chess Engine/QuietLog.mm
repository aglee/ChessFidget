//
//  QuietLog.m
//
//  Created by Andy Lee on 9/12/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "QuietLog.h"

void QuietLog(NSString *format, ...)
{
	va_list argList;
	va_start(argList, format);
	{{
		NSString *message = [[NSString alloc] initWithFormat:format arguments:argList];
		fprintf(stderr, "%s\n", message.UTF8String);
	}}
	va_end(argList);
}

