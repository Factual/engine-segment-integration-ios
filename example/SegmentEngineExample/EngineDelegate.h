/*
 * Use of this software is subject to the terms and
 * conditions of the license agreement between you
 * and Factual Inc
 *
 * Copyright © 2019 Factual Inc. All rights reserved.
 */

#ifndef EngineDelegate_h
#define EngineDelegate_h

#import "FactualEngine.h"

@interface EngineDelegate : NSObject <FactualEngineDelegate>
+ (FactualEngine *)engine;
@end

#endif /* EngineDelegate_h */
