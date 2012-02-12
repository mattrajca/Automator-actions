//
//  DropView.h
//  Run External Script
//
//  Copyright Matt Rajca 2011-2012. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol DropViewDelegate;

@interface DropView : NSView {
  @private
	NSArray *_supportedFileExtensions;
	NSURL *_fileURL;
	__weak  id < DropViewDelegate > _delegate;
	
	BOOL _highlighted;
}

@property (nonatomic, retain) NSArray *supportedFileExtensions;
@property (nonatomic, copy) NSURL *fileURL;

@property (nonatomic, assign) __weak id < DropViewDelegate > delegate;

@end


@protocol DropViewDelegate < NSObject >

- (void)dropViewDidReceiveFile:(NSURL *)url;

@end
