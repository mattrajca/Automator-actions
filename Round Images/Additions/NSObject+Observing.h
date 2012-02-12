//
//  NSObject+Observing.h
//  Round Images
//
//  Copyright (c) 2012 Matt Rajca. All rights reserved.
//

@interface NSObject (Observing)

- (void)addObserver:(NSObject *)observer forKeyPaths:(NSArray *)keyPaths options:(NSKeyValueObservingOptions)options;

@end
