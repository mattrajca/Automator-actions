//
//  ImageProcessor.m
//  Round Images
//
//  Copyright (c) 2012 Matt Rajca. All rights reserved.
//

#import "ImageProcessor.h"

#import "NSBezierPath+StrokeExtensions.h"

@implementation ImageProcessor

@synthesize topLeftCorner = _topLeftCorner, topRightCorner = _topRightCorner;
@synthesize bottomRightCorner = _bottomRightCorner, bottomLeftCorner = _bottomLeftCorner;
@synthesize cornerRadius = _cornerRadius, borderWidth = _borderWidth, borderColor = _borderColor;

- (id)init {
	self = [super init];
	if (self) {
		self.topLeftCorner = self.topRightCorner = self.bottomRightCorner = self.bottomLeftCorner = YES;
		
		self.cornerRadius = 4.0f;
		self.borderWidth = 2.0f;
		self.borderColor = [NSColor blackColor];
	}
	return self;
}

- (void)dealloc {
	[_borderColor release];
	
	[super dealloc];
}

- (void)completeRoundedPath:(NSBezierPath *)path withOuterRect:(NSRect)outerRect innerRect:(NSRect)innerRect radius:(CGFloat)radius {
	[path moveToPoint:outerRect.origin];
	
	if (self.bottomLeftCorner) {
		[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(innerRect), NSMinY(innerRect)) radius:radius startAngle:180.0 endAngle:270.0];
	}
	else {
		[path lineToPoint:NSMakePoint(NSMinX(outerRect), NSMinY(outerRect))];
	}
	
	if (self.bottomRightCorner) {
		[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(innerRect), NSMinY(innerRect)) radius:radius startAngle:270.0 endAngle:360.0];
	}
	else {
		[path lineToPoint:NSMakePoint(NSMaxX(outerRect), NSMinY(outerRect))];
	}
	
	if (self.topRightCorner) {
		[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(innerRect), NSMaxY(innerRect)) radius:radius startAngle:  0.0 endAngle: 90.0];
	}
	else {
		[path lineToPoint:NSMakePoint(NSMaxX(outerRect), NSMaxY(outerRect))];
	}
	
	if (self.topLeftCorner) {
		[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(innerRect), NSMaxY(innerRect)) radius:radius startAngle: 90.0 endAngle:180.0];
	}
	else {
		[path lineToPoint:NSMakePoint(NSMinX(outerRect), NSMaxY(outerRect))];
	}
	
	[path closePath];
}

- (NSBitmapImageRep *)processInputImageRep:(NSBitmapImageRep *)imageRep {
	CGFloat outputWidth = [imageRep pixelsWide] + self.borderWidth * 2;
	CGFloat outputHeight = [imageRep pixelsHigh] + self.borderWidth * 2;
	
	NSRect outputRect = NSMakeRect(0.0f, 0.0f, outputWidth, outputHeight);
	NSRect innerRect = NSInsetRect(outputRect, self.cornerRadius, self.cornerRadius);
	
	NSRect outerClipRect = NSInsetRect(outputRect, self.borderWidth / 2, self.borderWidth / 2);
	NSRect innerClipRect = NSInsetRect(outerClipRect, self.cornerRadius, self.cornerRadius);
	
	NSBitmapImageRep *outputRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
																		  pixelsWide:outputWidth
																		  pixelsHigh:outputHeight
																	   bitsPerSample:8
																	 samplesPerPixel:4
																			hasAlpha:YES
																			isPlanar:NO
																	  colorSpaceName:NSCalibratedRGBColorSpace
																		 bytesPerRow:outputWidth * 4
																		bitsPerPixel:32];
	
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:outputRep]];
	
	[[NSColor clearColor] set];
	NSRectFill(outputRect);
	
	NSBezierPath *borderPath = [NSBezierPath bezierPath];
	[self completeRoundedPath:borderPath withOuterRect:outputRect innerRect:innerRect radius:self.cornerRadius];
	
	NSBezierPath *clipPath = [NSBezierPath bezierPath];
	[self completeRoundedPath:clipPath withOuterRect:outerClipRect innerRect:innerClipRect radius:self.cornerRadius];
	
	[[NSGraphicsContext currentContext] saveGraphicsState];
	[clipPath setClip];
	
	[imageRep drawInRect:outputRect fromRect:NSZeroRect operation:NSCompositeSourceOver
				fraction:1.0f respectFlipped:YES hints:nil];
	
	[[NSGraphicsContext currentContext] restoreGraphicsState];
	
	[self.borderColor set];
	
	[borderPath setLineWidth:self.borderWidth];
	[borderPath strokeInside];
	
	[NSGraphicsContext restoreGraphicsState];
	
	return [outputRep autorelease];
}

@end
