//
//  RunExternalScript.h
//  Run External Script
//
//  Copyright Matt Rajca 2011-2012. All rights reserved.
//

#import <Automator/AMBundleAction.h>

#import "DropView.h"

@interface RunExternalScript : AMBundleAction < DropViewDelegate > {
  @private
	NSPopUpButton *shellPopUp;
	DropView *dropView;
}

@property (nonatomic, assign) IBOutlet NSPopUpButton *shellPopUp;
@property (nonatomic, assign) IBOutlet DropView *dropView;

@end
