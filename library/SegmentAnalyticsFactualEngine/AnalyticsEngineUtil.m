/*
 * Use of this software is subject to the terms and
 * conditions of the license agreement between you
 * and Factual Inc
 *
 * Copyright © 2017-2018 Factual Inc. All rights reserved.
 */

#import <AdSupport/ASIdentifierManager.h>
#import "AnalyticsEngine.h"

@implementation AnalyticsEngineUtil

NSString *USER_JOURNEY_CIRC_ID = @"factual-segment-user-journey-circ-id";
NSString *USER_JOURNEY_CIRC_EXPR = @"(at any-factual-place)";

+ (void) trackUserJourneyWithEngine:(FactualEngine *)engine forAnalytics:(SEGAnalytics *)analytics {
    [self addUserJourneyActionHandlerTo:engine forAnalytics:analytics];
    FactualCircumstance *userJourneyCircumstance = [[FactualCircumstance alloc] initWithId:USER_JOURNEY_CIRC_ID expr:USER_JOURNEY_CIRC_EXPR actionId:[AnalyticsEngineUserJourneyActionHandler actionId]];
    [engine registerCircumstance:userJourneyCircumstance];
}

+ (void) addUserJourneyActionHandlerTo:(FactualEngine *)engine forAnalytics:(SEGAnalytics *)analytics {
    AnalyticsEngineUserJourneyActionHandler *userJourneyActionHandler = [[AnalyticsEngineUserJourneyActionHandler alloc] initForAnalytics:analytics];
    [engine registerActionWithId:[AnalyticsEngineUserJourneyActionHandler actionId] listener:userJourneyActionHandler];
}

+ (void) logPlaceEntered:(FactualPlace *)factualPlace incidentId:(NSString *)incidentId forAnalytics:(SEGAnalytics *)analytics {
    [self logPlaceVisit:factualPlace incidentId:incidentId eventName:@"Place Entered" forAnalytics:analytics];
}

+ (void) logPlaceNear:(FactualPlace *)factualPlace incidentId:(NSString *)incidentId forAnalytics:(SEGAnalytics *)analytics {
    [self logPlaceVisit:factualPlace incidentId:incidentId eventName:@"Place Near" forAnalytics:analytics];
}

+ (void) logPlaceVisit:(FactualPlace *)factualPlace incidentId:(NSString *)incidentId eventName:(NSString *)eventName forAnalytics:(SEGAnalytics *)analytics {
    NSDictionary *eventContext = [self segmentEventContext];
    NSDictionary *eventProps = [self segmentEventPropsForPlace:factualPlace];
    [eventProps setValue:incidentId forKey:@"incident_id"];
    [analytics track:eventName properties:eventProps options:eventContext];
}

+ (NSDictionary *) segmentEventContext {
    BOOL isAdvertisingTrackingEnabled = [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
    NSDictionary *eventContext = @{
      @"context": @{
        @"device": @{
          @"deviceId": [[[UIDevice currentDevice] identifierForVendor] UUIDString],
          @"advertisingId": [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString],
          @"adTrackingEnabled": [NSNumber numberWithBool:isAdvertisingTrackingEnabled]
        }
      },
      @"integrations": @{
        @"Factual": @{
          @"name": @"Engine",
          @"version": [FactualEngine sdkVersion]
        }
      }
    };
    return eventContext;
}

+ (NSDictionary *) segmentEventPropsForPlace: (FactualPlace *) factualPlace {
    NSMutableDictionary *props = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                  [NSNumber numberWithDouble:[factualPlace latitude]], @"latitude",
                                  [NSNumber numberWithDouble:[factualPlace longitude]], @"longitude",
                                  [NSNumber numberWithDouble:[factualPlace distance]], @"accuracy",
                                  [factualPlace factualId], @"place_id",
                                  [factualPlace name], @"place_name",
                                  [[factualPlace toDict] valueForKey:@"threshold_met"], @"confidence",
                                  nil];
    if([factualPlace chainId] != nil) {
        NSString *chainId = [[factualPlace chainId] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if([chainId length] > 0) {
            [props setValue:[factualPlace chainId] forKey:@"place_chain_id"];
        }
    }
    if([factualPlace categoryIds]) {
        NSMutableArray<NSString *> *cats = [[NSMutableArray alloc] init];
        for(NSNumber *categoryId in [factualPlace categoryIds]) {
            [cats addObject:[categoryId stringValue]];
        }
        [props setValue:cats forKey:@"place_categories"];
    }
    return props;
}

@end
