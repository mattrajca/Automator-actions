//
//  RoundImages.h
//  Round Images
//
//  Copyright (c) 2012 Matt Rajca. All rights reserved.
//

#import <Automator/AMBundleAction.h>

@class ImageProcessor;

@interface RoundImages : AMBundleAction {
  @private
	NSImageView *_previewView;
	
	ImageProcessor *_processor;
}

@property (nonatomic, assign) IBOutlet NSImageView *previewView;

@property (nonatomic, readonly) ImageProcessor *processor;

@end
