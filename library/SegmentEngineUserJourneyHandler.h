/*
 * Use of this software is subject to the terms and
 * conditions of the license agreement between you
 * and Factual Inc
 *
 * Copyright © 2019 Factual Inc. All rights reserved.
 */

#ifndef SegmentEngineUserJourneyHandler_h
#define SegmentEngineUserJourneyHandler_h

#import "FactualEngine.h"

@interface SegmentEngineUserJourneyHandler : NSObject<UserJourneyDelegate>
- (id) initWithMaxAttachedPlaceEventsPerEvent:(int)maxAttachedPlaceEventsPerEvent;
- (id) init;
@end


#endif /* SegmentEngineUserJourneyHandler_h */
