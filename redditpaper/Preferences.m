//
//  Preferences.m
//  redditpaper
//
//  Created by Rob Lourens on 1/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Preferences.h"

static Preferences *prefs = nil;

@implementation Preferences

@synthesize autoChangeCheck, randomCheck, autoChangePeriod, autoChangeType, openAtLoginCheck, defaults;

+ (Preferences *)sharedPrefs {
	if (prefs == nil) {
		prefs = [[Preferences alloc] init];
	}
	
	return prefs;
}

- (id)init {
	self = [self initWithWindowNibName:@"Preferences"];
	self.defaults = [NSUserDefaults standardUserDefaults];
	
	[self setupDefaults];
	
	return self;
}

- (void)windowDidLoad {
	[self syncDisplayToDefaults];
	
	[autoChangePeriod setSendsActionOnEndEditing:YES];
}

- (void)syncDisplayToDefaults {
	// Set auto change prefs
	autoChangeCheck.state = [defaults boolForKey:RPAutoChangeEnabledDefaultsKey];
	autoChangePeriod.stringValue = [defaults objectForKey:RPAutoChangePeriodDefaultsKey];
	[autoChangeType setTitle:[autoChangeType itemTitleAtIndex:[defaults integerForKey:RPAutoChangeTypeIndexDefaultsKey]]];
	
	randomCheck.state = [defaults boolForKey:RPRandomOrderDefaultsKey];
	openAtLoginCheck.state = [defaults boolForKey:RPOpenAtLoginDefaultsKey];
}

- (void)setupDefaults {	
	[[NSUserDefaults standardUserDefaults] registerDefaults:
	 [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
										  [NSNumber numberWithBool:NO],
										  @"1",
										  [NSNumber numberWithInt:2],
										  [NSNumber numberWithBool:NO],
										  [NSNumber numberWithBool:NO], nil]
								 forKeys:[NSArray arrayWithObjects:
										  RPAutoChangeEnabledDefaultsKey,
										  RPAutoChangePeriodDefaultsKey,
										  RPAutoChangeTypeIndexDefaultsKey,
										  RPRandomOrderDefaultsKey,
										  RPOpenAtLoginDefaultsKey, nil]]];
	[defaults synchronize];
}

- (IBAction)checkClicked:(id)sender {
	switch ([sender tag]) {
		case 0:
			[defaults setBool:(BOOL)[sender state] forKey:RPAutoChangeEnabledDefaultsKey];
			break;
		case 1:
			[defaults setBool:(BOOL)[sender state] forKey:RPRandomOrderDefaultsKey];
			break;
		case 2:
			[defaults setBool:(BOOL)[sender state] forKey:RPSkipNSFWDefaultsKey];
			break;
		case 3:
			[defaults setBool:(BOOL)[sender state] forKey:RPOpenAtLoginDefaultsKey];
			if ((BOOL)[sender state])
				[self addAppAsLoginItem];
			else
				[self removeAppAsLoginItem];
			break;
		default:
			break;
	}
	
	[defaults synchronize];
}

// Login item code from http://cocoatutorial.grapewave.com/tag/lssharedfilelistcreate/
-(void)addAppAsLoginItem {
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
	
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath]; 
	
	// Create a reference to the shared file list.
	// We are adding it to the current user only.
	// If we want to add it all users, use
	// kLSSharedFileListGlobalLoginItems instead of
	//kLSSharedFileListSessionLoginItems
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
															kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		//Insert an item to the list.
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
																	 kLSSharedFileListItemLast, NULL, NULL,
																	 url, NULL, NULL);
		if (item){
			CFRelease(item);
		}
	}

	CFRelease(loginItems);
}

-(void)removeAppAsLoginItem {
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
	
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath];
	
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
															kLSSharedFileListSessionLoginItems, NULL);
	
	if (loginItems) {
		UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray  *loginItemsArray = (NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
		int i = 0;
		for(i ; i< [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)[loginItemsArray
																		objectAtIndex:i];
			//Resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(NSURL*)url path];
				if ([urlPath compare:appPath] == NSOrderedSame){
					LSSharedFileListItemRemove(loginItems,itemRef);
				}
			}
		}
		[loginItemsArray release];
	}
}

- (IBAction)autoChangePeriodSet:(id)sender {
	NSLog(@"period set");
	[defaults setObject:[autoChangePeriod stringValue] forKey:RPAutoChangePeriodDefaultsKey];
	[defaults synchronize];
}

- (IBAction)autoChangeTypeSet:(id)sender {
	NSLog(@"type set");
	[defaults setInteger:[autoChangeType indexOfSelectedItem] forKey:RPAutoChangeTypeIndexDefaultsKey];
	[defaults synchronize];
}

// Necessary since the NSTextFieldCell doesn't know that editing is finished when the done button is clicked
- (void)doneClicked:(id)sender {
	NSLog(@"clicked done");
	[self autoChangePeriodSet:nil];
	
	[self.window close];
}

- (void)dealloc {
	[super dealloc];
	[defaults synchronize];
	[defaults release];
}

@end
