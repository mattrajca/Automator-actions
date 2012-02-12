//
//  CreatePDFThumbnail.m
//  Create PDF Thumbnail
//
//  Copyright Matt Rajca 2010-2012, All Rights Reserved.
//

#import "CreatePDFThumbnail.h"

#import <Quartz/Quartz.h>

@implementation CreatePDFThumbnail

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo {
	NSMutableArray *output = [[NSMutableArray alloc] init];
	
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
		
		if (!doc) {
			[self logMessageWithLevel:AMLogLevelError format:@"Could not load the PDF document: %@", path];
			continue;
		}
		
		if ([doc pageCount] > 0) {
			PDFPage *page = [doc pageAtIndex:0];
			
			NSImage *image = [[NSImage alloc] initWithData:[page dataRepresentation]];
			
			NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithData:[image TIFFRepresentation]];
			[image release];
			
			NSData *data = [rep representationUsingType:NSJPEGFileType properties:nil];
			[rep release];
			
			NSError *error = nil;
			NSString *newPath = [[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"jpg"];
			
			if (![data writeToFile:newPath options:NSDataWritingAtomic error:&error]) {
				[self logMessageWithLevel:AMLogLevelError format:@"Could not write the thumbnail to '%@'. Error: %@", newPath, error];
				continue;
			}
			
			[output addObject:newPath];
		}
		
		[doc release];
	}
	
	return [output autorelease];
}

@end
