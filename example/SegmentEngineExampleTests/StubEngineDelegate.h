/*
 * Use of this software is subject to the terms and
 * conditions of the license agreement between you
 * and Factual Inc
 *
 * Copyright © 2019 Factual Inc. All rights reserved.
 */

#ifndef StubEngineDelegate_h
#define StubEngineDelegate_h

#import "SegmentEngine.h"
#import <XCTest/XCTest.h>

@interface StubEngineDelegate : UIResponder <FactualEngineDelegate>
@property FactualEngine *engine;
@property XCTestExpectation *engineStartedExpectation;
@end

#endif /* StubEngineDelegate_h */
