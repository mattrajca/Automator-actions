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
		NSURL *url = [NSURL fileURLWithPath:path];
		
		PDFDocument *doc = [[PDFDocument alloc] initWithURL:url];
		
		if ([doc pageCount] > 0) {
			PDFPage *page = [doc pageAtIndex:0];
			
			NSImage *image = [[NSImage alloc] initWithData:[page dataRepresentation]];
			
			NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithData:[image TIFFRepresentation]];
			[image release];
			
			NSString *newPath = [[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"jpg"];
			
			[[rep representationUsingType:NSJPEGFileType properties:nil] writeToFile:newPath
																		  atomically:YES];
			
			[rep release];
			
			[output addObject:newPath];
		}
		
		[doc release];
	}
	
	return [output autorelease];
}

@end
