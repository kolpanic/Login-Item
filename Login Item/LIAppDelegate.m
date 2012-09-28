//
//  LIAppDelegate.m
//  Login Item
//
//  Created by Karl Moskowski on 12-09-28.
//  Copyright (c) 2012 Voodoo Ergonomics Inc. All rights reserved.
//

#import "LIAppDelegate.h"

@implementation LIAppDelegate

@synthesize window = _window;

- (IBAction) openAccountsPrefs:(id)sender {
	NSString *scriptString = [NSString stringWithFormat:
	                          @"tell application \"System Preferences\"\n"
	                          "activate\n"
	                          "reveal anchor \"startupItemsPref\" of pane \"com.apple.preferences.users\"\n"
	                          "end tell\n"
	                          "tell application \"System Events\" to set frontmost of process \"%@\" to true",
	                          [[NSProcessInfo processInfo] processName]];
	NSAppleScript *script = [[NSAppleScript alloc] initWithSource:scriptString];
	[script executeAndReturnError:nil];
}

@end
