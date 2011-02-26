//
//  WallpaperController.h
//  redditpaper
//
//  Contains all logic related to changing the current wallpaper
//
//  Created by Rob Lourens on 1/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DataManager.h"
#import "ImageLoader.h"

@class redditpaperAppDelegate;
@interface WallpaperController : NSObject <ImageLoaderDelegate> {
	DataManager *_data;
	NSUInteger curIndex;
	
	redditpaperAppDelegate *delegate;
}

@property (nonatomic) NSUInteger curIndex;
@property (nonatomic, retain) redditpaperAppDelegate *delegate;

+ (WallpaperController *)getWallpaperController;

- (void)_startDataManager;
- (BOOL)_setWallpaperToPath:(NSString *)path;
- (void)_setWallpaperToIndex:(NSUInteger)index;

- (void)setNextWallpaperSkipNSFW:(BOOL)skip;
- (void)setPreviousWallpaperSkipNSFW:(BOOL)skip;
- (void)setRandomWallpaperSkipNSFW:(BOOL)skip;
- (void)setInitialWallpaperSkipNSFW:(BOOL)skip;

@end
