//
//  ImageLoader.m
//  redditpaper
//
//  Created by Rob Lourens on 2/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageLoader.h"


@implementation ImageLoader

@synthesize destPath, curConnection;

+ (id)imageLoaderWithRequest:(NSURLRequest *)request
					destPath:(NSString *)path
					delegate:(id<ImageLoaderDelegate>)delegate {
	return [[[self alloc] initWithRequest:request destPath:path delegate:delegate] autorelease];
}

- (id)initWithRequest:(NSURLRequest *)request
			 destPath:(NSString *)path
			 delegate:(id<ImageLoaderDelegate>)del {
	if (self = [super init]) {
		delegate = del;
		self.destPath = path;
		curData = [[NSMutableData alloc] init];
		self.curConnection = [NSURLConnection connectionWithRequest:request delegate:self];
	}
	
	return self;
}

- (void)cancel {
	if (curConnection != nil) {
		[curConnection cancel];
	}
}

#pragma mark NSURLConnection stuff
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[curData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[[NSFileManager defaultManager] createFileAtPath:destPath
											contents:curData
										  attributes:nil];
	[delegate gotImageAtPath:destPath];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Error while downloading: %@", [error localizedDescription]);
}

- (void)dealloc {
	if (curConnection != nil) {
		[curConnection release];
	}

	[curData release];
	[super dealloc];
}

@end
