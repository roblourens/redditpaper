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

#define RPSkipNSFWWallpaperArg @"skipnsfw"
#define RPMinWidthWallpaperArg @"minwidth"

@interface WallpaperController : NSObject{
    DataManager *_data;
    NSUInteger curIndex;
}

@property (nonatomic) NSUInteger curIndex;

+ (WallpaperController *)getWallpaperController;

- (void)_startDataManager;
- (BOOL)_setWallpaperToPath:(NSString *)path;
- (void)_setWallpaperToIndex:(NSUInteger)index;

- (void)setNextWallpaperWithArgs:(NSDictionary *)args;
- (void)setPreviousWallpaperWithArgs:(NSDictionary *)args;
- (void)setRandomWallpaperWithArgs:(NSDictionary *)args;
- (void)setInitialWallpaperWithArgs:(NSDictionary *)args;

@end
