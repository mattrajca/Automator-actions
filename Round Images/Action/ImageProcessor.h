//
//  ImageProcessor.h
//  Round Images
//
//  Copyright (c) 2012 Matt Rajca. All rights reserved.
//

@interface ImageProcessor : NSObject {
  @private
	BOOL _topLeftCorner;
	BOOL _topRightCorner;
	BOOL _bottomRightCorner;
	BOOL _bottomLeftCorner;
	
	CGFloat _cornerRadius;
	CGFloat _borderWidth;
	NSColor *_borderColor;
}

@property (nonatomic, assign) BOOL topLeftCorner;
@property (nonatomic, assign) BOOL topRightCorner;
@property (nonatomic, assign) BOOL bottomRightCorner;
@property (nonatomic, assign) BOOL bottomLeftCorner;

@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, retain) NSColor *borderColor;

- (NSBitmapImageRep *)processInputImageRep:(NSBitmapImageRep *)imageRep;

@end
