/*
 * Use of this software is subject to the terms and
 * conditions of the license agreement between you
 * and Factual Inc
 *
 * Copyright © 2017 Factual Inc. All rights reserved.
 */

#import <AdSupport/ASIdentifierManager.h>
#import "AnalyticsEngine.h"

@implementation AnalyticsEngineUtil

+ (void) trackAllPlaceVisitsWithEngine:(FactualEngine *)engine forAnalytics:(SEGAnalytics *)analytics {
    [self addDefaultActionHandlerTo:engine forAnalytics:analytics];
    FactualCircumstance *atAnyPlaceCircumstance = [[FactualCircumstance alloc] initWithId:@"factual-segment-default-circ-id" expr:@"(at any-factual-place)" actionId:[AnalyticsEngineDefaultActionHandler actionId]];
    [engine registerCircumstance:atAnyPlaceCircumstance];
}

+ (void) addDefaultActionHandlerTo:(FactualEngine *)engine forAnalytics:(SEGAnalytics *)analytics {
    AnalyticsEngineDefaultActionHandler *defaultActionHandler = [[AnalyticsEngineDefaultActionHandler alloc] initForAnalytics:analytics];
    [engine registerActionWithId:[AnalyticsEngineDefaultActionHandler actionId] listener:defaultActionHandler];
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
    if([factualPlace chainId]) {
        [props setValue:[factualPlace chainId] forKey:@"place_chain_id"];
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
