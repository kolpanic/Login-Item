//
//  LIAppDelegate.h
//  Login Item
//
//  Created by Karl Moskowski on 12-09-28.
//  Copyright (c) 2012 Voodoo Ergonomics Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LIAppDelegate : NSObject <NSApplicationDelegate>

- (IBAction) openAccountsPrefs:(id)sender;

@property (assign) IBOutlet NSWindow *window;

@end
