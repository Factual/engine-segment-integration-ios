/*
 * Use of this software is subject to the terms and
 * conditions of the license agreement between you
 * and Factual Inc
 *
 * Copyright © 2019 Factual Inc. All rights reserved.
 */

#import <XCTest/XCTest.h>
#import "StubConfiguration.h"
#import "StubEngineDelegate.h"
#import <Analytics/SEGAnalytics.h>

@interface SegmentEngineExampleTests : XCTestCase

@end

@implementation SegmentEngineExampleTests

StubEngineDelegate *engineDelegate;
SegmentEngineUserJourneyHandler *userJourneyHandler;

// Keys for Braze API
NSString *API_KEY = @"api_key";
NSString *EMAIL_KEY = @"email_address";
NSString *ID_KEY = @"external_id";
NSString *USERS_KEY = @"users";
NSString *CUSTOM_EVENTS_KEY = @"custom_events";
NSString *NAME_KEY = @"name";
NSString *EVENT_DATE_KEY = @"last";
NSString *COUNT_KEY = @"count";

- (void)setUp {
  // Set up engine if it isn't already
  if (![FactualEngine isEngineStarted]) {
    engineDelegate = [[StubEngineDelegate alloc] init];
    userJourneyHandler = [[SegmentEngineUserJourneyHandler alloc] initWithMaxAttachedPlaceEventsPerEvent:1];
    XCTestExpectation *engineStartedExpectation = [[XCTestExpectation alloc] initWithDescription:@"Engine started"];
    [engineDelegate setEngineStartedExpectation:engineStartedExpectation];
    
    [FactualEngine startWithApiKey:[StubConfiguration engineApiKey]
                          delegate:engineDelegate
               userJourneyDelegate:userJourneyHandler];
    
    SEGAnalyticsConfiguration *segmentConfig = [SEGAnalyticsConfiguration configurationWithWriteKey:[StubConfiguration
                                                                                                     segmentWriteKey]];
    segmentConfig.flushAt = 1;
    [SEGAnalytics setupWithConfiguration:segmentConfig];
    [SEGAnalytics debug:YES];
    
    [[SEGAnalytics sharedAnalytics] identify:[StubConfiguration testUserId]
                                      traits:@{ @"email": [StubConfiguration testEmail]}];
    
    (void)[XCTWaiter waitForExpectations:@[engineStartedExpectation] timeout:10];
  }
}

// Tests Segment Engine Circumstances by triggering a circumstance and having Segment Engine send it to Segment
// and having Segment push that data to Braze
- (void)testSegmentEngineCircumstances {
  // Get event names we're expecting to send to Segment
  NSString *circumstanceMetEventName = [@"engine_" stringByAppendingString:[StubConfiguration circumstanceName]];
  NSString *atPlaceEventName = [@"engine_at_" stringByAppendingString:[StubConfiguration circumstanceName]];
  
  // Get current counts for these events
  NSSet<NSString *> *events = [[NSSet alloc] initWithObjects:circumstanceMetEventName, atPlaceEventName, nil];
  NSDictionary *beforeEventCounts = [self getCountsForEvents:events];
  
  // Trigger a circumstance
  CLLocation *location = [[CLLocation alloc] initWithLatitude:[StubConfiguration testLatitude]
                                                    longitude:[StubConfiguration testLongitude]];
  [engineDelegate.engine runCircumstancesWithMockLocation:location];
  
  // Wait for Segment to send data to Braze
  [self delayFor:60.0];
  
  // Get counts for events aftet being tracked
  NSDictionary *afterEventCounts = [self getCountsForEvents:events];
  
  NSNumber *circumstanceCountBefore = (NSNumber *)[beforeEventCounts valueForKey:circumstanceMetEventName];
  NSNumber *circumstanceCountAfter = (NSNumber *)[afterEventCounts valueForKey:circumstanceMetEventName];
  XCTAssertEqual(circumstanceCountBefore.intValue + 1, circumstanceCountAfter.intValue);
  
  NSNumber *atPlaceCountBefore = (NSNumber *)[beforeEventCounts valueForKey:atPlaceEventName];
  NSNumber *atPlaceCountAfter = (NSNumber *)[afterEventCounts valueForKey:atPlaceEventName];
  XCTAssertEqual(atPlaceCountBefore.intValue + 1, atPlaceCountAfter.intValue);
}

// Tests Segment Engine Circumstances by having Segment Engine send a span to Segment and having Segment push that
// data to Braze
- (void)testSegmentEngineSpans {
  // Get event names we're expecting to send to Segment
  NSString *spanEventName = @"engine_span_occurred";
  NSString *attachedPlaceEventName = @"engine_span_attached_place";
  
  // Get current counts for these events
  NSSet<NSString *> *events = [[NSSet alloc] initWithObjects:spanEventName, attachedPlaceEventName, nil];
  NSDictionary *beforeEventCounts = [self getCountsForEvents:events];
  
  // Send a span to Segment
  [userJourneyHandler userJourneySpanDidOccur:[self createSpan]];
  
  // Wait for Segment to send data to Braze
  [self delayFor:60.0];
  
  // Get counts for events aftet being tracked
  NSDictionary *afterEventCounts = [self getCountsForEvents:events];
  
  NSNumber *spanCountBefore = (NSNumber *)[beforeEventCounts valueForKey:spanEventName];
  NSNumber *spanCountAfter = (NSNumber *)[afterEventCounts valueForKey:spanEventName];
  XCTAssertEqual(spanCountBefore.intValue + 1, spanCountAfter.intValue);
  
  NSNumber *attachedPlaceBefore = (NSNumber *)[beforeEventCounts valueForKey:attachedPlaceEventName];
  NSNumber *attachedPlaceAfter = (NSNumber *)[afterEventCounts valueForKey:attachedPlaceEventName];
  XCTAssertEqual(attachedPlaceBefore.intValue + 1, attachedPlaceAfter.intValue);
}

// Get the number of times an event has been sent to Braze from Segment
- (NSDictionary *)getCountsForEvents:(NSSet<NSString *> *)eventNames {
  NSMutableDictionary *counts = [[NSMutableDictionary alloc] init];
  for (NSString *eventName in eventNames) {
    [counts setValue:@(0) forKey:eventName];
  }
  // Ensure event was sent to Braze
  NSURLRequest *brazeRequest = [self getBrazeApiRequest];
  XCTestExpectation *brazeRequestExpectation = [[XCTestExpectation alloc] initWithDescription:@"Braze callback"];
  NSURLSession *session = [NSURLSession sharedSession];
  
  [[session dataTaskWithRequest:brazeRequest
              completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                // Check for error
                XCTAssertNil(error, @"Error returned: %@", [error description]);
                
                // Get JSON data
                NSDictionary *reply = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:nil];
                // Find our test user
                NSArray<NSDictionary *> *users = (NSArray *)[reply valueForKey:USERS_KEY];
                if (!users || users.count == 0) {
                  // No events have been sent to Segment yet
                  return;
                }
                NSPredicate *predicate = [NSPredicate predicateWithBlock:
                                          ^BOOL(id  _Nullable evaluatedObject,
                                                NSDictionary<NSString *,id> * _Nullable bindings) {
                                            NSString *name = (NSString *)[(NSDictionary *)evaluatedObject objectForKey:ID_KEY];
                                            return [name isEqualToString:[StubConfiguration testUserId]];
                                          }];
                NSArray<NSDictionary *> *testUser = [users filteredArrayUsingPredicate:predicate];
                if (!testUser) {
                  // No events have been sent to Segment yet
                  return;
                }
                
                // Get custom events from user
                NSArray<NSDictionary *> *customEvents = [(NSDictionary *)[testUser firstObject]
                                                         valueForKey:CUSTOM_EVENTS_KEY];
                if (!customEvents || customEvents.count == 0) {
                  // No events have been sent to Segment yet
                  return;
                }
                
                // There are multiple events, find the circumstance related events
                for (NSDictionary *event in customEvents) {
                  // Get event name
                  NSString *eventName = (NSString *)[event valueForKey:NAME_KEY];
                  if (!eventName) {
                    // This event hasn't been sent to Segment
                    continue;
                  }
                  // Ensure this event was the one we sent
                  if ([eventNames containsObject:eventName]) {
                    NSNumber *count = (NSNumber *)[event objectForKey:COUNT_KEY];
                    [counts setObject:count forKey:eventName];
                  }
                }
                
                [brazeRequestExpectation fulfill];
              }] resume];
  
  (void)[XCTWaiter waitForExpectations:@[brazeRequestExpectation] timeout:30];
  
  return counts;
}

// Timed delay
- (void)delayFor:(double)seconds {
  XCTestExpectation *segmentTrackExpectation = [[XCTestExpectation alloc] initWithDescription:@"Delay for test"];
  dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC));
  dispatch_after(delay, dispatch_get_main_queue(), ^(void) { [segmentTrackExpectation fulfill]; });
  (void)[XCTWaiter waitForExpectations:@[segmentTrackExpectation] timeout:seconds + 30];
}

// Create a rest API request to braze to ensure our events were sent there
- (NSURLRequest *)getBrazeApiRequest {
  NSString *email = [StubConfiguration testEmail];
  NSString *apiKey = [StubConfiguration brazeRestApiKey];
  NSString *endpoint = [StubConfiguration brazeRestEndpoint];
  NSString *requestUrlString = [[NSString alloc] initWithFormat:@"https://%@/users/export/ids", endpoint];
  NSURL *requestUrl = [[NSURL alloc] initWithString:requestUrlString];
  
  NSMutableURLRequest *brazeRequest = [[NSMutableURLRequest alloc] initWithURL:requestUrl];
  NSDictionary *body = [[NSDictionary alloc] initWithObjectsAndKeys:apiKey, API_KEY, email, EMAIL_KEY, nil];
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingSortedKeys error:nil];
  NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
  NSData *requestData = [NSData dataWithBytes:[jsonString UTF8String]
                                       length:[jsonString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
  [brazeRequest setHTTPMethod:@"POST"];
  [brazeRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
  [brazeRequest setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
  [brazeRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]]
      forHTTPHeaderField:@"Content-Length"];
  
  [brazeRequest setHTTPBody:requestData];
  
  return brazeRequest;
}

// Creates a span to be sent to Segment
- (UserJourneySpan *)createSpan {
  CLLocation *visitLocation = [[CLLocation alloc] initWithLatitude:33.8003 longitude:-117.8827];
  
  FactualPlace *factualPlace = [[FactualPlace alloc] initWithName:@"Angel Stadium of Anaheim"
                                                        factualId:@"123"
                                                          chainId:nil
                                                      categoryIds:@[@372, @406]
                                                         distance:100
                                                         latitude:33.79992299247533
                                                        longitude:-117.8830901440233
                                                     thresholdMet:PlaceConfidenceThresholdHigh
                                                         locality:@"Anaheim"
                                                           region:@"CA"
                                                          country:@"us"
                                                         postcode:@"92806"];
  
  FactualPlaceVisit *placeVisit = [[FactualPlaceVisit alloc] initWithIngressLocation:visitLocation
                                                                      attachedPlaces:@[factualPlace]
                                                                         geographies:nil
                                                                              isHome:NO
                                                                              isWork:NO];
  
  return [[UserJourneySpan alloc] initWithSpanId:@"this-is-a-test"
                                  startTimestamp:[NSDate dateWithTimeIntervalSinceNow:-1000]
                       startTimestampUnavailable:NO
                                    endTimestamp:[NSDate date]
                         endTimestampUnavailable:NO
                                       didTravel:NO
                                   didLoseSignal:NO
                                    currentPlace:placeVisit
                                   previousPlace:nil
                                mainActivityType:NO_ACTIVITY
                                      activities:[[NSArray<FactualActivity *> alloc] init]];
}

@end
