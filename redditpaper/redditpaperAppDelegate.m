//
//  redditpaperAppDelegate.m
//  redditpaper
//
//  Created by Rob Lourens on 1/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "redditpaperAppDelegate.h"
#import "DataManager.h"
#import "WallpaperController.h"

@implementation redditpaperAppDelegate

@synthesize theMenu, curTimer, domainMenuItem, pauseMenuItem, pauseStartDate, prePauseFireDate, activityIndicatorVisible;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(_dataLoaded:)
                                                 name:kDataLoadedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(_setOrCancelTimerIfNeeded:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:[NSUserDefaults standardUserDefaults]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_reachabilityChanged:)
                                                 name:kReachabilityChangedNotification 
                                               object:nil];

    defaults = [NSUserDefaults standardUserDefaults];
    timerWaiting = NO;
    
    activityIndicatorVisible = NO;
    [[DataManager getDataManager] setAppDelegate:self];
    wc = [WallpaperController getWallpaperController];
}

- (void)_dataLoaded:(NSNotification *)note {
    NSString *minwidth = [defaults boolForKey:RPMinWidthEnabledDefaultsKey] ?
    [defaults stringForKey:RPMinWidthDefaultsKey] : @"0";
    [NSThread detachNewThreadSelector:@selector(setInitialWallpaperWithArgs:) 
                             toTarget:wc
                           withObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithBool:[defaults boolForKey:RPSkipNSFWDefaultsKey]],
                                       RPSkipNSFWWallpaperArg,
                                       minwidth, RPMinWidthWallpaperArg, nil]];

    [self _setOrCancelTimerIfNeeded:nil];
}

// Check whether timer prefs were set or changed, and set timer accordingly
- (void)_setOrCancelTimerIfNeeded:(NSNotification *)note {
    // If wallpapers should autochange...
    if ([defaults boolForKey:RPAutoChangeEnabledDefaultsKey]) {
        NSTimeInterval ti = [self _autoChangeIntervalInSeconds];
        
        // If there is no timer, or the autochange interval changed, start the timer
        if (curTimer == nil || ti != [curTimer timeInterval])
            [self _setTimer];
    }
    else
        [self _cancelTimer];
}

- (void)_resetTimerIfNeeded {
    if ([defaults boolForKey:RPAutoChangeEnabledDefaultsKey])
        [self _setTimer];
}

- (void)_setTimer {
    NSLog(@"Setting timer");
    if (curTimer != nil) {
        [self _cancelTimer];
    }
    
    self.curTimer = [NSTimer scheduledTimerWithTimeInterval:[self _autoChangeIntervalInSeconds]
                                                     target:self
                                                   selector:@selector(_advanceWallpaper:)
                                                   userInfo:nil
                                                    repeats:YES];
    if (self.pauseMenuItem.state == 1)
        [self _pauseTimer];
}

- (void)_cancelTimer {
    [curTimer invalidate];
    [curTimer release];
    curTimer = nil;
}

- (void)_setDomainText {
    NSString *domain = [[DataManager getDataManager] domainForIndex:wc.curIndex];
    [domainMenuItem setTitle:[NSString stringWithFormat:@"(%@)", domain]];
}

- (void)_advanceWallpaper:(NSTimer *)timer {
    if (reachable) {
        NSString *minwidth = [defaults boolForKey:RPMinWidthEnabledDefaultsKey] ?
        [defaults stringForKey:RPMinWidthDefaultsKey] : @"0";
        BOOL random = [defaults boolForKey:RPRandomOrderDefaultsKey];
        if (random)
            [NSThread detachNewThreadSelector:@selector(setRandomWallpaperWithArgs:)
                                     toTarget:wc
                                   withObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSNumber numberWithBool:[defaults boolForKey:RPSkipNSFWDefaultsKey]],
                                               RPSkipNSFWWallpaperArg,
                                               minwidth, RPMinWidthWallpaperArg, nil]];
        else
            [NSThread detachNewThreadSelector:@selector(setNextWallpaperWithArgs:)
                                     toTarget:wc
                                   withObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSNumber numberWithBool:[defaults boolForKey:RPSkipNSFWDefaultsKey]],
                                               RPSkipNSFWWallpaperArg,
                                               minwidth, RPMinWidthWallpaperArg, nil]];
    }
    // pause the timer
    else {
        [self.curTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:INFINITY]];
        timerWaiting = YES;
    }
    
    [self _setDomainText];
}

// Reads preferences to get the number of seconds to show each wallpaper
- (NSTimeInterval)_autoChangeIntervalInSeconds {
    int autoChangeDurs[4];
    autoChangeDurs[0] = 1;
    autoChangeDurs[1] = 60;
    autoChangeDurs[2] = 60*60;
    autoChangeDurs[3] = 60*60*24;
    
    double period = [[defaults objectForKey:RPAutoChangePeriodDefaultsKey] doubleValue];
    return period*autoChangeDurs[[defaults integerForKey:RPAutoChangeTypeIndexDefaultsKey]];
}

- (void)_reachabilityChanged:(NSNotification *)note {
    Reachability *reach = (Reachability *)[note object];
    reachable = ([reach currentReachabilityStatus] != NotReachable);
    
    // fire timer if waiting
    if (reachable) {
        if (timerWaiting) {
            NSLog(@"timer can finally fire");
            [curTimer fire];
            [curTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:[self _autoChangeIntervalInSeconds]]];
            timerWaiting = NO;
        }
    }
}

// Do menu set-up things
- (void)awakeFromNib {
    NSStatusBar *bar = [NSStatusBar systemStatusBar];

    theItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    [theItem retain];
    
    [theItem setImage:[NSImage imageNamed:@"sbicon.png"]];
    [theItem setHighlightMode:YES];
    [theItem setMenu:theMenu];
}

- (IBAction)nextClicked:(id)sender {
    NSString *minwidth = [defaults boolForKey:RPMinWidthEnabledDefaultsKey] ?
                                                    [defaults stringForKey:RPMinWidthDefaultsKey] : @"0";
    [NSThread detachNewThreadSelector:@selector(setNextWallpaperWithArgs:)
                             toTarget:wc
                           withObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithBool:[defaults boolForKey:RPSkipNSFWDefaultsKey]],
                                       RPSkipNSFWWallpaperArg,
                                       minwidth, RPMinWidthWallpaperArg, nil]];
    [self _resetTimerIfNeeded];
    [self _setDomainText];
}

- (IBAction)previousClicked:(id)sender {
    NSString *minwidth = [defaults boolForKey:RPMinWidthEnabledDefaultsKey] ?
                                                    [defaults stringForKey:RPMinWidthDefaultsKey] : @"0";
    [NSThread detachNewThreadSelector:@selector(setPreviousWallpaperWithArgs:)
                             toTarget:wc
                           withObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithBool:[defaults boolForKey:RPSkipNSFWDefaultsKey]],
                                       RPSkipNSFWWallpaperArg,
                                       minwidth, RPMinWidthWallpaperArg, nil]];
    [self _resetTimerIfNeeded];
    [self _setDomainText];
}

- (IBAction)preferencesClicked:(id)sender {
    Preferences *p = [Preferences sharedPrefs];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES]; 
    [[p window] makeKeyAndOrderFront:nil];
}

- (IBAction)goToRedditClicked:(id)sender {
    NSString *subURL = [[DataManager getDataManager] URLForSubmissionIndex:wc.curIndex];
    if (subURL == nil) {
        NSLog(@"Bad submission URL");
        return;
    }
    
    BOOL success = [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:subURL]];
    if (!success) {
        NSLog(@"Could not open the submission URL");
    }
}

- (IBAction)goToSourceClicked:(id)sender {
    NSString *sourceURL = [[DataManager getDataManager] URLForWallpaperIndex:wc.curIndex];
    if (sourceURL == nil) {
        NSLog(@"Bad source URL");
        return;
    }
    
    BOOL success = [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:sourceURL]];
    if (!success) {
        NSLog(@"Could not open the source URL");
    }
}

- (void)_pauseTimer {
    self.pauseStartDate = [NSDate date];
    self.prePauseFireDate = [curTimer fireDate];
    [curTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:INFINITY]];
    
    [pauseMenuItem setState:1];
}

- (IBAction)pauseClicked:(id)sender {
    // Pausing
    if (pauseMenuItem.state == 0) {
        [self _pauseTimer];
    }
    // un-pausing
    else {
        NSTimeInterval timePaused = -1*[pauseStartDate timeIntervalSinceNow];
        [curTimer setFireDate:[prePauseFireDate dateByAddingTimeInterval:timePaused]];
        [pauseMenuItem setState:0];
    }
}

- (IBAction)quitClicked:(id)sender {
    [[DataManager getDataManager] cleanUp];
    [[NSApplication sharedApplication] terminate:sender];
}

- (void)setActivityIndicatorVisible:(BOOL)visible {
    BOOL alreadyvisible = activityIndicatorVisible;
    activityIndicatorVisible = visible;
    if (visible) {
        if (!alreadyvisible) {
            [NSThread detachNewThreadSelector:@selector(_animateStatusBar) toTarget:self withObject:nil];
        }
    }
    else
        [theItem setImage:[NSImage imageNamed:@"sbicon.png"]];
}

- (void)_animateStatusBar {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSInteger i = 0;
    NSArray *images = [NSArray arrayWithObjects:@"load_0.png", @"load_1.png", @"load_2.png", @"load_3.png", nil];
    while (activityIndicatorVisible) {
        [theItem setImage:[NSImage imageNamed:[images objectAtIndex:i]]];
        i = (i+1)%[images count];
        [NSThread sleepForTimeInterval:.5]; 
    }
    [pool release];
}

@end
