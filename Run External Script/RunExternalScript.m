//
//  RunExternalScript.m
//  Run External Script
//
//  Copyright Matt Rajca 2011-2012. All rights reserved.
//

#import "RunExternalScript.h"

#import <OSAKit/OSAKit.h>

@implementation RunExternalScript

@synthesize shellPopUp, dropView;

+ (NSArray *)supportedScriptExtensions {
	return [NSArray arrayWithObjects:@"", @"php", @"pl", @"py", @"rb", @"sh", nil];
}

- (void)awakeFromNib {
	NSData *path = [[self parameters] objectForKey:@"path"];
	
	if (path) {
		BOOL stale = NO;
		NSError *error = nil;
		
		NSURL *url = [NSURL URLByResolvingBookmarkData:path
											   options:0
										 relativeToURL:NULL
								   bookmarkDataIsStale:&stale
												 error:&error];
		
		if (!url || stale) {
			NSLog(@"Invalid bookmark data. Error: %@ Stale: %d", error, stale);
			
			dropView.fileURL = nil;
		}
		else {
			dropView.fileURL = url;
		}
	}
	
	dropView.supportedFileExtensions = [[self class] supportedScriptExtensions];
	dropView.delegate = self;
}

- (void)dropViewDidReceiveFile:(NSURL *)url {
	NSError *error = nil;
	
	NSData *data = [url bookmarkDataWithOptions:NSURLBookmarkCreationMinimalBookmark
				 includingResourceValuesForKeys:nil
								  relativeToURL:nil
										  error:&error];
	
	if (!data) {
		NSLog(@"Cannot load the archived bookmark. Error: %@", error);
		return;
	}
	
	[[self parameters] setObject:data forKey:@"path"];
	
	NSString *ext = [url pathExtension];
	
	if ([ext isEqualToString:@"php"]) {
		[[self parameters] setObject:@"/usr/bin/php" forKey:@"shell"];
	}
	else if ([ext isEqualToString:@"pl"]) {
		[[self parameters] setObject:@"/usr/bin/perl" forKey:@"shell"];
	}
	else if ([ext isEqualToString:@"py"]) {
		[[self parameters] setObject:@"/usr/bin/python" forKey:@"shell"];
	}
	else if ([ext isEqualToString:@"rb"]) {
		[[self parameters] setObject:@"/usr/bin/ruby" forKey:@"shell"];
	}
	else if ([ext isEqualToString:@"sh"]) {
		[[self parameters] setObject:@"/bin/bash" forKey:@"shell"];
	}
}

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo {
	NSString *path = [dropView.fileURL path];
	
	if (!path) {
		*errorInfo = [NSDictionary dictionaryWithObject:@"The script path was not specified. Drag a script into the drop zone."
												 forKey:OSAScriptErrorMessage];
		
		return nil;
	}
	
	NSMutableArray *outputLines = [[NSMutableArray alloc] init];
	
	NSString *shell = [[self parameters] valueForKey:@"shell"];
	
	NSMutableArray *arguments = [NSMutableArray array];
	[arguments addObject:path];
	
	for (NSString *string in input) {
		NSArray *lines = [string componentsSeparatedByString:@"\n"];
		
		for (NSString *line in lines) {
			if ([line length]) {
				[arguments addObject:line];
			}
		}
	}
	
	NSTask *task = [[NSTask alloc] init];
	[task setLaunchPath:shell];
	[task setArguments:arguments];
	
	NSPipe *outPipe = [NSPipe pipe];
	[task setStandardOutput:outPipe];
	
	NSFileHandle *outHandle = [outPipe fileHandleForReading];
	
	outHandle.readabilityHandler = ^(NSFileHandle *handle) {
		
		NSData *data = [handle availableData];
		
		NSString *string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
		
		NSArray *lines = [string componentsSeparatedByString:@"\n"];
		[string release];
		
		for (NSString *line in lines) {
			if (![line length])
				continue;
			
			[outputLines addObject:line];
		}
		
	};
	
	[task launch];
	[task waitUntilExit];
	[task release];
	
	return [outputLines autorelease];
}

@end
