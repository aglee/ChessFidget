//
//  QuietLog.h
//
//  Created by Andy Lee on 9/12/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

extern void QuietLog(NSString *format, ...);

#define QLog QuietLog

#define MLog(fmt, ...) QLog(@"%@ %@ -- " fmt, self.className, NSStringFromSelector(_cmd), ##__VA_ARGS__)

