//
//  DataManager.m
//  redditpaper
//
//  Created by Rob Lourens on 1/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataManager.h"

static DataManager *sharedInstance = nil;

@implementation DataManager

@synthesize imageListings, hasData, appDelegate;

#pragma mark -
#pragma mark Singleton methods

+ (DataManager*)getDataManager {
    @synchronized(self) {
        if (sharedInstance == nil)
            sharedInstance = [[DataManager alloc] init];
    }
    return sharedInstance;
}

#pragma mark Data management methods
- (id)init {
    if (self = [super init]) {
        // path to the app's library- used to save state and wallpaper files
        libPath = [[@"~/Library/Application Support/redditpaper/" stringByExpandingTildeInPath] retain];
        
        // clean up in case wallpapers get left around
        [self removeOldWallpapers];
        
        // indicates whether the data should be updated at the next opportunity
        shouldUpdate = YES;
        
        // indicates whether data has been loaded
        hasData = NO;
        
        // create it if it doesn't exist
        fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:libPath])
            [fileManager createDirectoryAtPath:libPath 
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:nil];
        
        // Register for reachability notifications, start reachability
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name:kReachabilityChangedNotification object: nil];
        reach = [[Reachability reachabilityWithHostName: @"www.roblourens.com"] retain];
        [reach startNotifier];
    }
    
    return self;
}

// Called when the reachability status changes
- (void)reachabilityChanged:(NSNotification* )note {
    NSString *reachStr;
    status = [reach currentReachabilityStatus];

    switch (status) {
        case NotReachable:
            reachStr = @"unreachable";
            break;
        case ReachableViaWiFi:
            reachStr = @"wifi";
        case ReachableViaWWAN:
            reachStr = @"wwan";
            break;
        default:
            reachStr = @"unknown";
            break;
    }
    
    NSLog(@"Reachability status changed to %@", reachStr);
    
    // update if needed-
    // shouldUpdate will be set if could not update at the last opportunity
    if (shouldUpdate)
        [self loadData];
}

// Returns YES if the server is reachable, NO otherwise
- (BOOL)serverReachable {
    return status != NotReachable;
}

// Returns the path to the last wallpaper displayed
- (void)removeOldWallpapers {
    NSError *error = nil;
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:libPath error:&error];
    if (error)
        [NSApp presentError:error];
    
    // Search library for image files, remove
    for (NSString *path in contents) {
        if ([self isImage:path]) {
            [fileManager removeItemAtPath:[libPath stringByAppendingPathComponent:path] error:nil];
        }
    }
}

- (BOOL)isImage:(NSString *)path {
    NSString *ext = [[path pathExtension] lowercaseString];
    if ([ext isEqualToString:@"jpg"] || [ext isEqualToString:@"png"] ||
        [ext isEqualToString:@"gif"] || [ext isEqualToString:@"tif"] ||
        [ext isEqualToString:@"bmp"]) 
        return YES;
    else
        return NO;
}

// NSTimer callback for loadData
- (void)loadData:(NSTimer *)theTimer {
    [self loadData];
}

#define dataURL @"http://www.roblourens.com/rp/images.json"
#define loadIntervalHrs 12
#define pollIntervalS 1
- (void)loadData {
    if ([self serverReachable]) {
        NSLog(@"Updating data");
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        // Prepare URL request to download image json
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:dataURL]];
        
        // Perform request and get JSON back as a NSData object
        NSError *error = nil;
        NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
        if (error) {
            NSLog(@"Error connecting to roblourens.com: %@", [error description]);
            
            // Try again later
            [NSTimer scheduledTimerWithTimeInterval:pollIntervalS target:self selector:@selector(loadData:) userInfo:nil repeats:NO];
            return;
        }
        
        // Get JSON as a NSString from NSData response
        NSString *jsonString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        
        // parse the JSON response into an object
        // Here we're using NSArray since we're parsing an array of JSON image listing objects
        error = nil;
        imageListings = [[parser objectWithString:jsonString error:&error] retain];
        if (error) {
            NSLog(@"Error: %@", [error description]);
            return;
        }
        
        // Schedule the next update
        [NSTimer scheduledTimerWithTimeInterval:loadIntervalHrs*60*60 target:self selector:@selector(loadData:) userInfo:nil repeats:NO];
        
        // If successful, and with data, post a notification
        [[NSNotificationCenter defaultCenter] postNotificationName:kDataLoadedNotification object:self];
        
        shouldUpdate = NO;
        hasData = YES;
    }
    else {
        shouldUpdate = YES;
    }
}

// Returns the wallpaper for the given index. Returns nil if no wallpaper with that index
- (NSString *)URLForWallpaperIndex:(NSUInteger)index {
    if (index < [imageListings count])
        return [[imageListings objectAtIndex:index] valueForKey:@"image"];
    else
        return nil;
}

- (NSString *)URLForSubmissionIndex:(NSUInteger)index {
    if (index < [imageListings count])
        return [[imageListings objectAtIndex:index] valueForKey:@"sub"];
    else
        return nil;
}

- (NSString *)domainForIndex:(NSUInteger)index {
    if (index < [imageListings count])
        return [[imageListings objectAtIndex:index] valueForKey:@"domain"];
    else
        return @"unknown";
}

- (BOOL)nsfwForIndex:(NSUInteger)index {
    if (index < [imageListings count])
        return [[[imageListings objectAtIndex:index] valueForKey:@"nsfw"] intValue] ==1;
    else
        return 0;
}

- (NSUInteger)widthForIndex:(NSUInteger)index {
    NSString *imgPath = [self pathOfLoadedWallpaperIndex:index];
    NSImage *img = [[NSImage alloc] initWithContentsOfFile:imgPath];
    NSInteger w = img.size.width;
    [img release];
    return w;
}

// Loads the wallpaper with given index, returns the path, and returns nil if no wallpaper with that index
// Returns nil if something goes wrong (i.e. no network connection)
#define imgTimeout 5
- (NSString *)pathOfLoadedWallpaperIndex:(NSUInteger)index {
    NSLog(@"get %d", index);
    if (index >= [imageListings count]) {
        return @"";
    }
    
    // if image is already loaded, return path
    NSString *imgURL = [self URLForWallpaperIndex:index];
    NSString *imgName = [imgURL lastPathComponent];
    NSString *imgPath = [libPath stringByAppendingPathComponent:imgName];
    if ([fileManager fileExistsAtPath:imgPath]) {
        return imgPath;
    }
    
    NSURLRequest *imgRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imgURL]
                                                cachePolicy:0
                                            timeoutInterval:imgTimeout];
    [appDelegate setActivityIndicatorVisible:YES];
    NSLog(@"downloading %d", index);
    NSData *imgData = [NSURLConnection sendSynchronousRequest:imgRequest returningResponse:nil error:nil];
    if (imgData == nil)
        return @"";
    
    [fileManager createFileAtPath:imgPath
                         contents:imgData
                       attributes:nil];
    [appDelegate setActivityIndicatorVisible:NO];
    
    return imgPath;
}




- (void)cleanUp {
    [self removeOldWallpapers];
}

@end
