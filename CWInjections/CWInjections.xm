// Clear for ProWidgets
// Created by Julian (insanj) Weiss (c) 2014
// Source and license fully available on GitHub.

#include <Foundation/NSDistributedNotificationCenter.h>
#import "../CWDynamicReader.h"

%ctor {
	[[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"CWSavePath" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *block) {
		CWDynamicReader *saver = [[CWDynamicReader alloc] init];
		BOOL worked = [saver savePath];

		CWLOG(@"Saved path (%@) to Clear app from SpringBoard", worked ? @"YES" : @"NO");
	}];

	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"CWSavePath" object:nil];
}