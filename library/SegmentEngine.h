/*
 * Use of this software is subject to the terms and
 * conditions of the license agreement between you
 * and Factual Inc
 *
 * Copyright © 2019 Factual Inc. All rights reserved.
 */

#import "SegmentEngineUserJourneyHandler.h"
#import "FactualEngine.h"

@interface SegmentEngine : NSObject

/**
 Returns true if tracking spans is enabled and false if it is not.
 
 Call trackUserJourneySpans to start tracking circumstances and stopTrackingUserJourneySpans to stop tracking
 circumstances
 */
+ (BOOL)isTrackingSpans;

/**
 Sends a Circumstance Response to Segment as a custom event.  This method assumes that Segment has already been started.
 
 The following custom events may be sent:
 
 a) Event named "engine_" + CIRCUMSTANCE_NAME to represent the triggered circumstance.
 
 b) At most 10 events named "engine_at_" + CIRCUMSTANCE_NAME for each place the user is at which triggered the event.
 
 c) At most 20 events named "engine_near_" + CIRCUMSTANCE_NAME for each place the user is near which triggered the
 event.
 
 Based on the generality of the circumstance definition, Factual's Engine SDK may match multiple potential candidate
 places the user may have been at or near when the circumstance was triggered.
 
 @param circumstanceResponse A CircumstanceResponse given in the circumstancesMet: callback in the FactualEngineDelegate
 */
+ (void)pushToSegment:(CircumstanceResponse *)circumstanceResponse;

/**
 Sends a Circumstance Response to Segment as a custom event.  This method assumes that Segment has already been started.
 
 The following custom events may be sent:
 
 a) Event named "engine_" + CIRCUMSTANCE_NAME to represent the triggered circumstance.
 
 b) A developer defined max number of events named "engine_at_" + CIRCUMSTANCE_NAME for each place the user is at which
 triggered the event.
 
 c) A developer defined max number of events named "engine_near_" + CIRCUMSTANCE_NAME for each place the user is near
 which triggered the event.
 
 Based on the generality of the circumstance definition, Factual's Engine SDK may match multiple potential candidate
 places the user may have been at or near when the circumstance was triggered.
 
 @param circumstanceResponse A CircumstanceResponse given in the circumstancesMet: callback in the FactualEngineDelegate
 @param maxAtPlaceEvents max number of AtPlace events to send to Segment. Sent in order of decreasing confidence
 @param maxNearPlaceEvents max number of NearPlace events to send to Segment. Sent in order of decreasing confidence
 */
+ (void)pushToSegment:(CircumstanceResponse *)circumstanceResponse
withMaxAtPlaceEvents:(int)maxAtPlaceEvents
withMaxNearPlaceEvents:(int)maxNearPlaceEvents;

/**
 Configures Engine to push User Journey Spans to Segment as custom events.  This method assumes that both Segment and
 Engine have been started and you must set Engine's User Journey Delegate to SegmentEngineUserJourneyHandler prior to
 executing this method.
 
 The following events may be sent:
 
 a) Event named "engine_span_occurred" to represent the span.
 
 b) At most 20 (or a developer defined number when initializing SegmentEngineUserJourneyHandler) events named
 "engine_span_attached_place" for each attached place the user was at or near during the span.
 
 Based on the generality of the circumstance definition, Factual's Engine SDK may match multiple potential candidate
 places the user may have been at or near when the circumstance was triggered.
 */
+ (void)trackUserJourneySpans;

/** Disables Segment Engine's User Journey Span tracking */
+ (void)stopTrackingUserJourneySpans;

@end
