//
//  DropView.m
//  Run External Script
//
//  Copyright Matt Rajca 2011-2012. All rights reserved.
//

#import "DropView.h"

@implementation DropView

#define ICON_WIDTH 42.0f
#define LR_MARGIN 8.0f

@synthesize supportedFileExtensions = _supportedFileExtensions, fileURL = _fileURL;
@synthesize delegate = _delegate;

- (id)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self registerForDraggedTypes:[NSArray arrayWithObject: (NSString *) kUTTypeFileURL]];
	}
	return self;
}

- (void)dealloc {
	[_supportedFileExtensions release];
	[_fileURL release];
	
	[super dealloc];
}

- (NSURL *)URLFromDraggingInfo:(id<NSDraggingInfo>)info {
	NSPasteboardItem *item = [[[info draggingPasteboard] pasteboardItems] objectAtIndex:0];
	
	if (!item)
		return nil;
	
	NSString *stringURL = [item stringForType: (NSString *) kUTTypeFileURL];
	
	if (!stringURL)
		return nil;
	
	return [NSURL URLWithString:stringURL];
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
	return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
	self.fileURL = [self URLFromDraggingInfo:sender];
	
	[_delegate dropViewDidReceiveFile:_fileURL];
	
	return YES;
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
	NSURL *url = [self URLFromDraggingInfo:sender];
	
	if (!url)
		return NSDragOperationNone;
	
	if (![_supportedFileExtensions containsObject:[url pathExtension]])
		return NSDragOperationNone;
	
	_highlighted = YES;
	[self setNeedsDisplay:YES];
	
	return NSDragOperationLink;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender {
	_highlighted = NO;
	[self setNeedsDisplay:YES];
}

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)flag {
	return NSDragOperationLink;
}

- (void)draggingEnded:(id<NSDraggingInfo>)sender {
	[self draggingExited:sender];
}

- (void)drawRect:(NSRect)dirtyRect {
	NSRect bounds = NSInsetRect([self bounds], 1.0f, 1.0f);
	
	NSColor *color = _highlighted ? [NSColor blueColor] : [NSColor grayColor];
	[color set];
	
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:bounds
														 xRadius:4.0f
														 yRadius:4.0f];
	
	CGFloat dash[2] = { 6.0f, 4.0f };
	
	[path setLineDash:dash count:2 phase:0];
	[path setLineWidth:2.0f];
	[path stroke];
	
	if (!_fileURL) {
		NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
		[style setAlignment:NSCenterTextAlignment];
		
		NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
									color, NSForegroundColorAttributeName,
									[NSFont boldSystemFontOfSize:16.0f], NSFontAttributeName,
									style, NSParagraphStyleAttributeName, nil];
		
		[style release];
		
		[@"Drop a Script" drawInRect:NSMakeRect(NSMinX(bounds), 17.0f, NSWidth(bounds), 20.0f)
					  withAttributes:attributes];
	}
	else {
		NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:[_fileURL path]];
		NSRect iconFrame = NSMakeRect(NSMinX(bounds) + LR_MARGIN, 6.0f, ICON_WIDTH, ICON_WIDTH);
		
		[icon drawInRect:iconFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
		
		NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSFont boldSystemFontOfSize:14.0f], NSFontAttributeName, nil];
		
		CGFloat innerX = NSMaxX(iconFrame) + LR_MARGIN;
		NSString *filename = [[_fileURL path] lastPathComponent];
		
		[filename drawWithRect:NSMakeRect(innerX, 20.0f, NSMaxX(bounds) - innerX - LR_MARGIN, 18.0f)
					   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
					attributes:attributes];
	}
}

@end
