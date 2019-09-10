/*
 * Use of this software is subject to the terms and
 * conditions of the license agreement between you
 * and Factual Inc
 *
 * Copyright © 2019 Factual Inc. All rights reserved.
 */

#import <Analytics/SEGAnalytics.h>
#import "SegmentEngine.h"
#import "SegmentEngineUserJourneyHandler.h"
#import "PlaceCategoryMap.h"
#import "PlaceChainMap.h"

@implementation SegmentEngineUserJourneyHandler
{
  int _maxAttachedPlacesPerEvent;
}

// Keys
NSString *ENGINE_SPAN_EVENT_KEY = @"engine_span_occurred";
NSString *SPAN_ID_KEY = @"span_id";
NSString *SPAN_SOURCE_KEY = @"event-source";
NSString *SPAN_SOURCE_NAME = @"factual";

NSString *START_TIMESTAMP_UNAVAILABLE_KEY = @"start_time_unavailable";
NSString *END_TIMESTAMP_UNAVAILABLE_KEY = @"end_time_unavailable";
NSString *START_TIMESTAMP_KEY = @"start_timestamp";
NSString *END_TIMESTAM_KEY = @"end_timestamp";
NSString *DURATION_KEY = @"duration";

NSString *IS_HOME_KEY = @"is_home";
NSString *IS_WORK_KEY = @"is_work";
NSString *INGRESS_LATITUDE_KEY = @"ingress_latitude";
NSString *INGRESS_LONGITUDE_KEY = @"ingress_longitude";

NSString *COUNTRY_KEY = @"country";
NSString *LOCALITIES_KEY = @"localities";
NSString *POSTCODE_KEY = @"postcode";
NSString *REGION_KEY = @"region";

NSString *SPAN_ATTACHED_PLACE_EVENT_KEY = @"engine_span_attached_place";
NSString *ATTACHED_PLACE_NAME_KEY = @"name";
NSString *ATTACHED_PLACE_ID_KEY = @"factual_id";
NSString *ATTACHED_PLACE_LATITUDE_KEY = @"latitude";
NSString *ATTACHED_PLACE_LONGITUDE_KEY = @"longitude";
NSString *ATTACHED_PLACE_CATEGORIES_KEY = @"category_labels";
NSString *ATTACHED_PLACE_CHAIN_KEY = @"chain_name";
NSString *ATTACHED_PLACE_DISTANCE_KEY = @"distance";
NSString *ATTACHED_PLACE_LOCALITY_KEY = @"locality";

- (id) initWithMaxAttachedPlaceEventsPerEvent:(int)maxAttachedPlaceEventsPerEvent {
  if (self = [super init]) {
    _maxAttachedPlacesPerEvent = maxAttachedPlaceEventsPerEvent;
  }
  
  return self;
}

- (id) init {
  return [self initWithMaxAttachedPlaceEventsPerEvent:20];
}

- (void)userJourneyEventDidOccur:(nonnull UserJourneyEvent *)userJourneyEvent { /* Not supported */ }

- (void)userJourneySpanDidOccur:(nonnull UserJourneySpan *)userJourneySpan {
  // Only send span data packet when did travel is false and tracking User Journey Spans is enabled
  if (![SegmentEngine isTrackingSpans] || userJourneySpan.didTravel) {
    return;
  }
  
  // Span information
  NSString *spanId = userJourneySpan.spanId;
  BOOL startTimestampUnavailable = userJourneySpan.startTimestampUnavailable;
  BOOL endTimestampUnavailable = userJourneySpan.endTimestampUnavailable;
  UInt64 startTimestamp = userJourneySpan.startTimestamp.timeIntervalSince1970 * 1000;
  UInt64 endTimestamp = userJourneySpan.endTimestamp.timeIntervalSince1970 * 1000;
  
  // Current place information
  FactualPlaceVisit *currentPlace = userJourneySpan.currentPlace;
  NSNumber *isHome = [[NSNumber alloc] initWithBool:currentPlace.isHome];
  NSNumber *isWork = [[NSNumber alloc] initWithBool:currentPlace.isWork];
  
  // Ingress information
  CLLocation *ingressLocation = currentPlace.ingressLocation;
  NSNumber *ingressLatitude = @(ingressLocation.coordinate.latitude);
  NSNumber *ingressLongitude = @(ingressLocation.coordinate.longitude);
  
  // Geographies information
  Geographies *geographies = currentPlace.geographies;
  NSString *country = geographies.country;
  NSArray<NSString*> *localities = geographies.localities;
  NSString *postcode = geographies.postcode;
  NSString *region = geographies.region;
  
  // Get duration of span
  NSNumber *duration = !startTimestampUnavailable && !endTimestampUnavailable ? @(endTimestamp - startTimestamp) : @(0);
  
  // Populate properties data
  NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
  [properties setValue:spanId forKey:SPAN_ID_KEY];
  [properties setValue:SPAN_SOURCE_NAME forKey:SPAN_SOURCE_KEY];
  [properties setValue:@(startTimestampUnavailable) forKey:START_TIMESTAMP_UNAVAILABLE_KEY];
  [properties setValue:@(endTimestampUnavailable) forKey:END_TIMESTAMP_UNAVAILABLE_KEY];
  [properties setValue:@(startTimestamp) forKey:START_TIMESTAMP_KEY];
  [properties setValue:@(endTimestamp) forKey:END_TIMESTAM_KEY];
  [properties setValue:duration forKey:DURATION_KEY];
  [properties setValue:isHome forKey:IS_HOME_KEY];
  [properties setValue:isWork forKey:IS_WORK_KEY];
  [properties setValue:ingressLatitude forKey:INGRESS_LATITUDE_KEY];
  [properties setValue:ingressLongitude forKey:INGRESS_LONGITUDE_KEY];
  [properties setValue:country forKey:COUNTRY_KEY];
  [properties setValue:localities forKey:LOCALITIES_KEY];
  [properties setValue:postcode forKey:POSTCODE_KEY];
  [properties setValue:region forKey:REGION_KEY];
  
  // Send data to Segment
  NSLog(@"Sending user journey span event to Segment");
  [[SEGAnalytics sharedAnalytics] track:ENGINE_SPAN_EVENT_KEY properties:properties];
  
  // Get number of attached places to send
  NSArray<FactualPlace *> *places = currentPlace.attachedPlaces;
  NSUInteger numPlaceEvents = MIN(_maxAttachedPlacesPerEvent, places.count);
  
  // Send attached places data if there are any to send
  if (numPlaceEvents > 0) {
    NSLog(@"Sending %@ attached place event(s) to Segment", [@(numPlaceEvents) stringValue]);
    [self sendPlacesData:currentPlace.attachedPlaces withSpanId:spanId withNumAttachedPlaces:numPlaceEvents];
  }
}

- (void)sendPlacesData:(NSArray<FactualPlace *>*)places
            withSpanId:(NSString *)spanId
 withNumAttachedPlaces:(NSUInteger)numAttachedPlaces {
  NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
  [properties setValue:spanId forKey:SPAN_ID_KEY];
  
  // Loop through all attached places
  for (int i = 0; i < numAttachedPlaces; i++) {
    FactualPlace *place = places[i];
    
    // Populate properties data
    [properties setValue:ATTACHED_PLACE_NAME_KEY forKey:place.name];
    [properties setValue:[PlaceCategoryMap getCategoriesFromPlace:place] forKey:ATTACHED_PLACE_CATEGORIES_KEY];
    [properties setValue:[PlaceChainMap getChainFromPlace:place] forKey:ATTACHED_PLACE_CHAIN_KEY];
    [properties setValue:place.factualId forKey:ATTACHED_PLACE_ID_KEY];
    [properties setValue:@(place.latitude) forKey:ATTACHED_PLACE_LATITUDE_KEY];
    [properties setValue:@(place.longitude) forKey:ATTACHED_PLACE_LONGITUDE_KEY];
    [properties setValue:@(place.distance) forKey:ATTACHED_PLACE_DISTANCE_KEY];
    [properties setValue:place.locality forKey:ATTACHED_PLACE_LOCALITY_KEY];
    [properties setValue:place.region forKey:REGION_KEY];
    [properties setValue:place.country forKey:COUNTRY_KEY];
    [properties setValue:place.postcode forKey:POSTCODE_KEY];
    
    // Send data to Segment
    [[SEGAnalytics sharedAnalytics] track:SPAN_ATTACHED_PLACE_EVENT_KEY properties:properties];
  }
}

@end

