//
//  ImageLoader.h
//  redditpaper
//
//  Created by Rob Lourens on 2/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ImageLoaderDelegate

- (void)gotImageAtPath:(NSString *)path;

@end

@interface ImageLoader : NSObject {
	NSURLConnection *curConnection;
	NSMutableData *curData;
	
	NSString *destPath;
	id<ImageLoaderDelegate> delegate;
}

@property (nonatomic, retain) NSString *destPath;
@property (nonatomic, retain) NSURLConnection *curConnection;

+ (id)imageLoaderWithRequest:(NSURLRequest *)request
					destPath:(NSString *)path
					delegate:(id<ImageLoaderDelegate>)delegate;

- (id)initWithRequest:(NSURLRequest *)request
			 destPath:(NSString *)path
			 delegate:(id<ImageLoaderDelegate>)delegate;

- (void)cancel;

@end
