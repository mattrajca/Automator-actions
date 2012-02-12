//
//  NSObject+Observing.m
//  Round Images
//
//  Copyright (c) 2012 Matt Rajca. All rights reserved.
//

#import "NSObject+Observing.h"

@implementation NSObject (Observing)

- (void)addObserver:(NSObject *)observer forKeyPaths:(NSArray *)keyPaths options:(NSKeyValueObservingOptions)options {
	for (NSString *path in keyPaths) {
		[self addObserver:observer forKeyPath:path options:options context:NULL];
	}
}

@end
