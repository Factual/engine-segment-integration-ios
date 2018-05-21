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

+ (void) addTrackActionTo:(FactualEngine *)engine forAnalytics:(SEGAnalytics *)analytics {
    AnalyticsEngineTrackAction *trackAction = [[AnalyticsEngineTrackAction alloc] initForAnalytics:analytics];
    [engine registerActionWithId:[AnalyticsEngineTrackAction actionId] listener:trackAction];
}

+ (void) logPlaceEntered:(FactualCircumstance *)circumstance place:(FactualPlace *)place incidentId:(NSString *)incidentId forAnalytics:(SEGAnalytics *)analytics {
    [self logPlaceVisitFromCircumstance:[circumstance circumstanceId] circumstanceExpression: [circumstance expr] place:place incidentId:incidentId eventName:@"Place Entered" forAnalytics:analytics];
}

+ (void) logPlaceApproached:(FactualCircumstance *)circumstance place:(FactualPlace *)place incidentId:(NSString *)incidentId forAnalytics:(SEGAnalytics *)analytics {
    [self logPlaceVisitFromCircumstance:[circumstance circumstanceId] circumstanceExpression: [circumstance expr] place:place incidentId:incidentId eventName:@"Place Approached" forAnalytics:analytics];
}

+ (void) logPlaceVisitFromCircumstance: (NSString *)circId circumstanceExpression: (NSString *)circExpr place:(FactualPlace *)factualPlace incidentId:(NSString *)incidentId eventName:(NSString *) eventName forAnalytics:(SEGAnalytics *)analytics {
    NSDictionary *eventProperties = @{
      @"circumstance_id": circId,
      @"circumstance_expression": circExpr
    };
    [self logPlaceVisit:factualPlace incidentId:incidentId eventName:eventName eventProperties:eventProperties forAnalytics:analytics];
}

+ (void) trackUserJourneyEvent:(UserJourneyEvent *) userJourneyEvent forAnalytics:(SEGAnalytics *)analytics {
    NSString *incidentId = [[NSUUID UUID] UUIDString];
    
    NSLog(@"User Journey Event Occurred: %@", [userJourneyEvent toDict]);
    if ([userJourneyEvent visitUpdate]) {
        NSLog(@"Visit Update Occurred: %@", [userJourneyEvent toDict]);
    }	
    if ([userJourneyEvent activityUpdate]) {
        NSLog(@"Activity Update Occurred: %@", [userJourneyEvent toDict]);
    }
    if ([userJourneyEvent appStateUpdate]) {
        NSLog(@"App State Update Occurred: %@", [userJourneyEvent toDict]);
    }
    if ([userJourneyEvent placeAttachmentUpdate]) {
        NSLog(@"PA Update Occurred: %@", [userJourneyEvent toDict]);
        for(FactualPlace *factualPlace in [[userJourneyEvent placeAttachmentUpdate] newlyAttachedPlaces]) {
            [self logPlaceEntered:factualPlace incidentId:incidentId forAnalytics:analytics];
        }
    }
}

+ (void) logPlaceEntered:(FactualPlace *)factualPlace incidentId:(NSString *)incidentId forAnalytics:(SEGAnalytics *)analytics {
    [self logPlaceVisit:factualPlace incidentId:incidentId eventName:@"Place Entered" eventProperties:nil forAnalytics:analytics];
}

+ (void) logPlaceApproached:(FactualPlace *)factualPlace incidentId:(NSString *)incidentId forAnalytics:(SEGAnalytics *)analytics {
    [self logPlaceVisit:factualPlace incidentId:incidentId eventName:@"Place Approached" eventProperties:nil forAnalytics:analytics];
}

+ (void) logPlaceVisit:(FactualPlace *)factualPlace incidentId:(NSString *)incidentId eventName:(NSString *)eventName eventProperties: (NSDictionary *) eventProps forAnalytics:(SEGAnalytics *)analytics {
    NSMutableDictionary *segmentEventProps = [[NSMutableDictionary alloc] initWithDictionary:[self segmentEventPropsForPlace:factualPlace]];
    [segmentEventProps setValue:incidentId forKey:@"incident_id"];
    if(eventProps) {
        [segmentEventProps addEntriesFromDictionary:eventProps];
    }
    [analytics track:eventName properties:segmentEventProps options:[self segmentEventContext]];
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
