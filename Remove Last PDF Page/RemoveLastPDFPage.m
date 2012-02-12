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
		NSURL *url = [NSURL fileURLWithPath:path];
		
		PDFDocument *doc = [[PDFDocument alloc] initWithURL:url];
		
		if ([doc pageCount] > 0) {
			[doc removePageAtIndex:[doc pageCount] - 1];
			[doc writeToURL:url];
		}
		
		[doc release];
	}
	
	return input;
}

@end
