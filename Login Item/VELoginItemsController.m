//
//  VELoginItemsController.m
//  Backup Client
//
//  Created by Karl Moskowski on 12-09-28.
//  Copyright (c) 2012 Voodoo Ergonomics Inc. All rights reserved.
//

#import "VELoginItemsController.h"

NSString *const kIsInLoginItems = @"isInLoginItems";

// this flag prevents methods bouncing back & forth due to KVO when app is added or removed via System Prefs
static BOOL receivedLoginItemsListChangedNotificiation;

static void LoginItemsListChanged(LSSharedFileListRef list, void *context) {
	receivedLoginItemsListChangedNotificiation = YES;
	[VELoginItemsController sharedInstance].isInLoginItems = [[VELoginItemsController sharedInstance] isApplicationInItemList:list];
}

@implementation VELoginItemsController

#pragma mark -
#pragma mark KVO

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kIsInLoginItems]) {
		if (!receivedLoginItemsListChangedNotificiation) {
			if (self.isInLoginItems)
				[self addToLoginItems];
			else
				[self removeFromLoginItems];
		}
		receivedLoginItemsListChangedNotificiation = NO;
	}
}

#pragma mark -
#pragma mark Login Items Management

- (void) addToLoginItems {
	LSSharedFileListRef list = LSSharedFileListCreate(kCFAllocatorDefault, kLSSharedFileListSessionLoginItems, NULL);
	if (list) {
		if (![self isApplicationInItemList:list]) {
			CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
			if (url) {
				NSDictionary *properties = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:self.addHidden] forKey:@"com.apple.loginitem.HideOnLaunch"];
				LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(list, kLSSharedFileListItemLast, NULL, NULL, url, (__bridge CFDictionaryRef)properties, NULL);
				if (item)
					CFRelease(item);
			}
		}
		CFRelease(list);
	}
}

- (void) removeFromLoginItems {
	LSSharedFileListRef list = LSSharedFileListCreate(kCFAllocatorDefault, kLSSharedFileListSessionLoginItems, NULL);
	if (list) {
		if ([self isApplicationInItemList:list]) {
			CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
			if (url) {
				UInt32 seed;
				CFArrayRef items = LSSharedFileListCopySnapshot(list, &seed);
				if (items) {
					for (id item in(__bridge NSArray *) items) {
						LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)item;
						if (LSSharedFileListItemResolve(itemRef, 0, &url, NULL) == noErr)
							if ([[(__bridge NSURL *) url path] hasPrefix:[[NSBundle mainBundle] bundlePath]])
								LSSharedFileListItemRemove(list, itemRef);
					}
					CFRelease(items);
				}
			}
		}
		CFRelease(list);
	}
}

- (BOOL) isApplicationInItemList:(LSSharedFileListRef)list {
	BOOL flag = NO;
	UInt32 seed;
	CFArrayRef items = LSSharedFileListCopySnapshot(list, &seed);
	if (items) {
		CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
		if (url) {
			for (id item in(__bridge NSArray *) items) {
				LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)item;
				if (LSSharedFileListItemResolve(itemRef, 0, &url, NULL) == noErr) {
					if ([[(__bridge NSURL *) url path] hasPrefix:[[NSBundle mainBundle] bundlePath]]) {
						flag = YES;
						break;
					}
				}
			}
		}
		CFRelease(items);
	}
	return flag;
}

#pragma mark -
#pragma mark Setup

static VELoginItemsController *sharedInstance = nil;

+ (VELoginItemsController *) sharedInstance {
	if (sharedInstance == nil)
		sharedInstance = [[self alloc] init];
	return sharedInstance;
}

- (id) init {
	if (sharedInstance == nil) {
		self = [super init];
		static dispatch_once_t pred;
		dispatch_once(&pred, ^{
            self.addHidden = NO;
            [self addObserver:self forKeyPath:kIsInLoginItems options:NSKeyValueObservingOptionNew context:nil];
            LSSharedFileListRef list = LSSharedFileListCreate(kCFAllocatorDefault, kLSSharedFileListSessionLoginItems, nil);
            if (list) {
                LSSharedFileListAddObserver(list, [[NSRunLoop currentRunLoop] getCFRunLoop], kCFRunLoopDefaultMode, LoginItemsListChanged, NULL);
                receivedLoginItemsListChangedNotificiation = YES;
                self.isInLoginItems = [self isApplicationInItemList:list];
            }
            sharedInstance = self;
        });
	}
	return sharedInstance;
}

- (void) dealloc {
	[self removeObserver:self forKeyPath:kIsInLoginItems];
	LSSharedFileListRef list = LSSharedFileListCreate(kCFAllocatorDefault, kLSSharedFileListSessionLoginItems, NULL);
	if (list) {
		LSSharedFileListRemoveObserver(list, [[NSRunLoop currentRunLoop] getCFRunLoop], kCFRunLoopDefaultMode, LoginItemsListChanged, NULL);
		CFRelease(list);
	}
}

@synthesize isInLoginItems, addHidden;

@end
