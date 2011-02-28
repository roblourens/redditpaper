//
//  WallpaperController.m
//  redditpaper
//
//  Created by Rob Lourens on 1/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WallpaperController.h"

static WallpaperController *sharedInstance = nil;

@implementation WallpaperController

@synthesize curIndex;

#pragma mark -
#pragma mark Singleton methods

+ (WallpaperController *)getWallpaperController {
    @synchronized(self) {
        if (sharedInstance == nil)
            sharedInstance = [[WallpaperController alloc] init];
    }
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        [self _startDataManager];
    }
    
    return self;
}

#pragma mark Wallpaper managing methods
- (void)setInitialWallpaperWithArgs:(NSDictionary *)args {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    BOOL skip = [[args valueForKey:RPSkipNSFWWallpaperArg] boolValue];
    NSUInteger minWidth = [[args valueForKey:RPMinWidthWallpaperArg] intValue];
    
    if (_data.imageListings != nil && [_data.imageListings count] > 0) {
        NSUInteger index = 0;
        while (([_data nsfwForIndex:index] && skip) || [_data widthForIndex:index] < minWidth)
            index = (index + 1) % [_data.imageListings count];

        [self _setWallpaperToIndex:index];
    }
    [pool release];
}

// Sets the wallpaper to the wallpaper with given index
// If any problems occur, does nothing
- (void)_setWallpaperToIndex:(NSUInteger)index {
    curIndex = index;
    NSString *path = [_data pathOfLoadedWallpaperIndex:index];
    if (![path isEqualToString:@""]) {
		[self _setWallpaperToPath:path];
	}
	else 
		NSLog(@"Could not set the wallpaper");
}

// Sets the wallpaper to the wallpaper with given path
// If there is no wallpaper for that path, returns NO
- (BOOL)_setWallpaperToPath:(NSString *)path {
    if (path == nil)
        return NO;
    
    // Checks whether the given path is valid
    BOOL isDirectory = NO;
    if(![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] || isDirectory) {
        NSLog(@"File does not exist, or is a directory");
        return NO;
    }
    
    NSURL *imageURL = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    NSScreen *curScreen = [NSScreen mainScreen];
    [[NSWorkspace sharedWorkspace] setDesktopImageURL:imageURL forScreen:curScreen options:nil error:&error];
    if (error) {
        [NSApp presentError:error];
        return NO;
    }
    
    return YES;
}

- (void)setNextWallpaperWithArgs:(NSDictionary *)args {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    BOOL skip = [[args valueForKey:RPSkipNSFWWallpaperArg] boolValue];
    NSUInteger minWidth = [[args valueForKey:RPMinWidthWallpaperArg] intValue];
    
    NSUInteger index = (curIndex + 1) % [_data.imageListings count];
    while (([_data nsfwForIndex:index] && skip) || [_data widthForIndex:index] < minWidth) {
        index = (index + 1) % [_data.imageListings count];
    }
    [self _setWallpaperToIndex:index];
    [pool release];
}

- (void)setPreviousWallpaperWithArgs:(NSDictionary *)args {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    BOOL skip = [[args valueForKey:RPSkipNSFWWallpaperArg] boolValue];
    NSUInteger minWidth = [[args valueForKey:RPMinWidthWallpaperArg] intValue];
    
    NSUInteger index;
    if (curIndex == 0)
        index = [_data.imageListings count] - 1;
    else
        index = curIndex - 1;
    
    while (([_data nsfwForIndex:index] && skip) || [_data widthForIndex:index] < minWidth)
        if (curIndex == 0)
            index = [_data.imageListings count] - 1;
        else
            index = index - 1;
    
    [self _setWallpaperToIndex:index];
    [pool release];
}

- (void)setRandomWallpaperWithArgs:(NSDictionary *)args {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    BOOL skip = [[args valueForKey:RPSkipNSFWWallpaperArg] boolValue];
    NSUInteger minWidth = [[args valueForKey:RPMinWidthWallpaperArg] intValue];
    
    NSUInteger index = abs(arc4random() % [_data.imageListings count]);
    while (index == curIndex || ([_data nsfwForIndex:index] && skip) || [_data widthForIndex:index] < minWidth)
        index = abs(arc4random() % [_data.imageListings count]);
    
    [self _setWallpaperToIndex:index];
    [pool release];
}

#pragma mark Utility methods
- (void)_startDataManager {
    _data = [DataManager getDataManager];
    [_data loadData];
}

@end
