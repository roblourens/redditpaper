//
//  DataManager.h
//  redditpaper
//
//  Created by Rob Lourens on 1/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JSON.h"
#import "Reachability.h"
#import "redditpaperAppDelegate.h"
#import "ImageLoader.h"

#define kDataLoadedNotification @"DataLoadedNotification"

@interface DataManager : NSObject {
	NSFileManager *fileManager;
	NSString *libPath;
	Reachability *reach;
	BOOL shouldUpdate;
	NetworkStatus status;
	BOOL hasData;
	redditpaperAppDelegate *appDelegate;
	
	// data loading
	ImageLoader *curImgLoader;

	NSArray *imageListings;
}

@property (nonatomic, retain) NSArray *imageListings;
@property (nonatomic, retain) redditpaperAppDelegate *appDelegate;
@property (nonatomic) BOOL hasData;

+ (DataManager*)getDataManager;
- (void)loadData;
- (NSString *)URLForWallpaperIndex:(NSUInteger)index;
- (NSString *)URLForSubmissionIndex:(NSUInteger)index;
- (NSString *)domainForIndex:(NSUInteger)index;
- (BOOL)isImage:(NSString *)path;
- (void) reachabilityChanged: (NSNotification* )note;
- (BOOL)serverReachable;
- (void)loadData:(NSTimer *)theTimer;
- (void)removeOldWallpapers;
- (void)pathOfLoadedWallpaperIndex:(NSUInteger)index delegate:(id<ImageLoaderDelegate>)delegate;
- (void)cleanUp;
- (BOOL)nsfwForIndex:(NSUInteger)index;

@end
