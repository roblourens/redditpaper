//
//  redditpaperAppDelegate.h
//  redditpaper
//
//  Created by Rob Lourens on 1/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Preferences.h"
#import "Reachability.h"

@class WallpaperController;
@interface redditpaperAppDelegate : NSObject <NSApplicationDelegate> {
    WallpaperController *wc;
    NSTimer *curTimer;
    NSUserDefaults *defaults;
    NSDate *pauseStartDate;
    NSDate *prePauseFireDate;
    BOOL reachable;
    BOOL timerWaiting;
    BOOL activityIndicatorVisible;
    NSStatusItem *theItem;
    
    IBOutlet NSMenu *theMenu;
    IBOutlet NSMenuItem *domainMenuItem, *pauseMenuItem;
}

@property (assign) IBOutlet NSMenu *theMenu;
@property (nonatomic, retain) NSTimer *curTimer;
@property (nonatomic, retain) NSDate *pauseStartDate;
@property (nonatomic, retain) NSDate *prePauseFireDate;
@property (nonatomic) BOOL activityIndicatorVisible;

@property (nonatomic, retain) IBOutlet NSMenuItem *domainMenuItem, *pauseMenuItem;

- (IBAction)nextClicked:(id)sender;
- (IBAction)previousClicked:(id)sender;
- (IBAction)preferencesClicked:(id)sender;
- (IBAction)goToRedditClicked:(id)sender;
- (IBAction)goToSourceClicked:(id)sender;
- (IBAction)pauseClicked:(id)sender;
- (IBAction)quitClicked:(id)sender;


- (void)_dataLoaded:(NSNotification *)note;
- (void)_setOrCancelTimerIfNeeded:(NSNotification *)note;
- (void)_setTimer;
- (void)_cancelTimer;
- (void)_setDomainText;
- (NSTimeInterval)_autoChangeIntervalInSeconds;
- (void)_advanceWallpaper:(NSTimer *)timer;
- (void)_reachabilityChanged:(NSNotification *)note;
- (void)_pauseTimer;
- (void)_resetTimerIfNeeded;
- (void)_animateStatusBar;

@end
