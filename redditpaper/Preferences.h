//
//  Preferences.h
//  redditpaper
//
//  Created by Rob Lourens on 1/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define RPAutoChangeEnabledDefaultsKey @"autochange"
#define RPAutoChangePeriodDefaultsKey @"autochangeperiod"
#define RPAutoChangeTypeIndexDefaultsKey @"autochangetype"
#define RPRandomOrderDefaultsKey @"random"
#define RPOpenAtLoginDefaultsKey @"login"
#define RPSkipNSFWDefaultsKey @"nsfwignore"

@interface Preferences : NSWindowController<NSTextDelegate> {
	IBOutlet NSButton *autoChangeCheck;
	IBOutlet NSButton *randomCheck;
	IBOutlet NSButton *openAtLoginCheck;
	IBOutlet NSTextFieldCell *autoChangePeriod;
	IBOutlet NSPopUpButton *autoChangeType;
	
	NSUserDefaults *defaults;
}

@property (nonatomic, retain) IBOutlet NSButton *autoChangeCheck;
@property (nonatomic, retain) IBOutlet NSButton *randomCheck;
@property (nonatomic, retain) IBOutlet NSTextFieldCell *autoChangePeriod;
@property (nonatomic, retain) IBOutlet NSPopUpButton *autoChangeType;
@property (nonatomic, retain) IBOutlet NSButton *openAtLoginCheck;

@property (nonatomic, assign) NSUserDefaults *defaults;

+ (Preferences *)sharedPrefs;
- (void)syncDisplayToDefaults;

- (IBAction)checkClicked:(id)sender;
- (IBAction)autoChangePeriodSet:(id)sender;
- (IBAction)autoChangeTypeSet:(id)sender;
- (void)doneClicked:(id)sender;

- (void)setupDefaults;
-(void)addAppAsLoginItem;
-(void)removeAppAsLoginItem;

@end
