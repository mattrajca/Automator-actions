//
//  RemoveLastPDFPage.m
//  Remove Last PDF Page
//
//  Copyright Matt Rajca 2010-2012, All Rights Reserved.
//

#import "RemoveLastPDFPage.h"

#import <Quartz/Quartz.h>

@implementation RemoveLastPDFPage

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo {
	for (NSString *path in input) {
		if (![[path pathExtension] isEqualToString:@"pdf"]) {
			[self logMessageWithLevel:AMLogLevelWarn format:@"Skipping '%@' since it is not a PDF", path];
			continue;
		}
		
		NSURL *url = [NSURL fileURLWithPath:path];
		
		if (!url) {
			[self logMessageWithLevel:AMLogLevelError format:@"The path '%@' is invalid", path];
			continue;
		}
		
		PDFDocument *doc = [[PDFDocument alloc] initWithURL:url];
		
		if ([doc pageCount] > 0) {
			[doc removePageAtIndex:[doc pageCount] - 1];
			
			if (![doc writeToURL:url]) {
				[self logMessageWithLevel:AMLogLevelError format:@"Could not save the modified PDF"];
			}
		}
		
		[doc release];
	}
	
	return input;
}

@end
