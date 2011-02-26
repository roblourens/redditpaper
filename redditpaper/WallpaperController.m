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

@synthesize curIndex, delegate;

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
- (void)setInitialWallpaperSkipNSFW:(BOOL)skip {
	if (_data.imageListings != nil && [_data.imageListings count] > 0) {
		NSUInteger index = 0;
		while ([_data nsfwForIndex:index] && skip)
			index = (curIndex + 1) % [_data.imageListings count];

		[self _setWallpaperToIndex:index];
	}
}

// Sets the wallpaper to the wallpaper with given index
// If any problems occur, does nothing
- (void)_setWallpaperToIndex:(NSUInteger)index {
	curIndex = index;
	[_data pathOfLoadedWallpaperIndex:index delegate:self];
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

- (void)setNextWallpaperSkipNSFW:(BOOL)skip {
	NSUInteger index = (curIndex + 1) % [_data.imageListings count];
	while ([_data nsfwForIndex:index] && skip)
		index = (curIndex + 1) % [_data.imageListings count];
	[self _setWallpaperToIndex:index];
}

- (void)setPreviousWallpaperSkipNSFW:(BOOL)skip {
	NSUInteger index;
	if (curIndex == 0)
		index = [_data.imageListings count] - 1;
	else
		index = curIndex - 1;
	
	while ([_data nsfwForIndex:index] && skip)
		if (curIndex == 0)
			index = [_data.imageListings count] - 1;
		else
			index = curIndex - 1;
	
	[self _setWallpaperToIndex:index];
}

- (void)setRandomWallpaperSkipNSFW:(BOOL)skip {
	NSUInteger index = abs(arc4random() % [_data.imageListings count]);
	while (index == curIndex || ([_data nsfwForIndex:index] && skip))
		index = abs(arc4random() % [_data.imageListings count]);
	
	[self _setWallpaperToIndex:index];
}
																			   
#pragma mark ImageLoaderDelegate methods
- (void)gotImageAtPath:(NSString *)path {
	NSLog(@"Setting wallpaper to index: %d", curIndex);
	if (![path isEqualToString:@""]) {
		[self _setWallpaperToPath:path];
	}
	else 
		NSLog(@"Could not set the wallpaper");
	
	[delegate setActivityIndicatorVisible:NO];
}

#pragma mark Utility methods
- (void)_startDataManager {
	_data = [DataManager getDataManager];
	[_data loadData];
}

@end
