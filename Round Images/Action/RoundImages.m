//
//  RoundImages.m
//  Round Images
//
//  Copyright (c) 2012 Matt Rajca. All rights reserved.
//

#import "RoundImages.h"

#import "ImageProcessor.h"
#import "NSObject+Observing.h"

@interface RoundImages ()

- (void)refreshPreview;

@end


@implementation RoundImages

@synthesize previewView = _previewView, processor = _processor;

- (id)init {
	self = [super init];
	if (self) {
		_processor = [[ImageProcessor alloc] init];
	}
	return self;
}

- (void)dealloc {
	[_processor release];
	
	[super dealloc];
}

- (void)awakeFromNib {
	NSArray *interestingPaths = [NSArray arrayWithObjects:@"cornerRadius", @"borderWidth", @"borderColor",
								 @"bottomLeftCorner", @"bottomRightCorner", @"topRightCorner", @"topLeftCorner", nil];
	
	[_processor addObserver:self forKeyPaths:interestingPaths options:0];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	[self refreshPreview];
}

- (void)refreshPreview {
	NSString *path = [[NSBundle bundleWithIdentifier:@"com.MattRajca.Automator.RoundImages"] pathForResource:@"Food"
																									  ofType:@"jpg"];
	
	NSBitmapImageRep *inputRep = [NSBitmapImageRep imageRepWithContentsOfFile:path];
	NSBitmapImageRep *outputRep = [_processor processInputImageRep:inputRep];
	
	_previewView.image = [[[NSImage alloc] initWithData:[outputRep TIFFRepresentation]] autorelease];
}

- (void)parametersUpdated {
	NSMutableDictionary *parameters = [self parameters];
	
	_processor.topLeftCorner = [[parameters objectForKey:@"TopLeft"] boolValue];
	_processor.topRightCorner = [[parameters objectForKey:@"TopRight"] boolValue];
	_processor.bottomRightCorner = [[parameters objectForKey:@"BottomRight"] boolValue];
	_processor.bottomLeftCorner = [[parameters objectForKey:@"BottomLeft"] boolValue];
	
	NSData *data = [parameters objectForKey:@"BorderColor"];
	
	_processor.cornerRadius = [[parameters objectForKey:@"CornerRadius"] floatValue];
	_processor.borderWidth = [[parameters objectForKey:@"BorderWidth"] floatValue];
	_processor.borderColor = data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : [NSColor blackColor];
	
	[self refreshPreview];
}

- (void)updateParameters {
	NSMutableDictionary *parameters = [self parameters];
	
	[parameters setObject:[NSNumber numberWithBool:_processor.topLeftCorner] forKey:@"TopLeft"];
	[parameters setObject:[NSNumber numberWithBool:_processor.topRightCorner] forKey:@"TopRight"];
	[parameters setObject:[NSNumber numberWithBool:_processor.bottomRightCorner] forKey:@"BottomRight"];
	[parameters setObject:[NSNumber numberWithBool:_processor.bottomLeftCorner] forKey:@"BottomLeft"];
	
	[parameters setObject:[NSNumber numberWithFloat:_processor.cornerRadius] forKey:@"CornerRadius"];
	[parameters setObject:[NSNumber numberWithFloat:_processor.borderWidth] forKey:@"BorderWidth"];
	[parameters setObject:[NSKeyedArchiver archivedDataWithRootObject:_processor.borderColor] forKey:@"BorderColor"];
}

- (NSBitmapImageFileType)fileTypeForPathExtension:(NSString *)extension {
	if ([extension isEqualToString:@"bmp"]) {
		return NSBMPFileType;
	}
	else if ([extension isEqualToString:@"gif"]) {
		return NSGIFFileType;
	}
	else if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"jpeg"]) {
		return NSJPEGFileType;
	}
	else if ([extension isEqualToString:@"png"]) {
		return NSPNGFileType;
	}
	else if ([extension isEqualToString:@"tif"] || [extension isEqualToString:@"tiff"]) {
		return NSTIFFFileType;
	}
	
	return NSNotFound;
}

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo {
	if (![input isKindOfClass:[NSArray class]]) {
		return nil;
	}
	
	[self parametersUpdated];
	
	for (NSString *path in input) {
		NSBitmapImageRep *inputRep = [NSBitmapImageRep imageRepWithContentsOfFile:path];
		
		if (!inputRep) {
			NSLog(@"Could not create a bitmap image rep");
			continue;
		}
		
		NSBitmapImageFileType fileType = [self fileTypeForPathExtension:[path pathExtension]];
		
		if (fileType == NSNotFound) {
			NSLog(@"Invalid image file extension (%@)", [path pathExtension]);
			continue;
		}
		
		NSBitmapImageRep *outputRep = [_processor processInputImageRep:inputRep];
		
		NSError *error = nil;
		NSData *data = [outputRep representationUsingType:fileType properties:nil];
		
		if (![data writeToFile:path options:NSDataWritingAtomic error:&error]) {
			NSLog(@"Could not write output file. Error: %@", error);
			continue;
		}
	}
	
	return input;
}

@end
