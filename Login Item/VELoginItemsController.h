//
//  VELoginItemsController.h
//  Backup Client
//
//  Created by Karl Moskowski on 12-09-28.
//  Copyright (c) 2012 Voodoo Ergonomics Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VELoginItemsController : NSObject

+ (VELoginItemsController *)	sharedInstance;
- (void)			addToLoginItems;
- (void)			removeFromLoginItems;
- (BOOL)			isApplicationInItemList:(LSSharedFileListRef)list;

// bind this to a an element in an XIB (e.g., the value of a check-box)
@property (assign) BOOL isInLoginItems;

// defaults to NO; set in -applicationDidFinishLaunching (or other method at app start-up)
@property (assign) BOOL addHidden;

@end
