/*
 * Use of this software is subject to the terms and
 * conditions of the license agreement between you
 * and Factual Inc
 *
 * Copyright © 2017-2018 Factual Inc. All rights reserved.
 */

#import "AnalyticsEngine.h"

@implementation AnalyticsEngineUserJourneyActionHandler
{
    SEGAnalytics *analytics;
}

+ (NSString *) actionId {
    return @"factual-segment-user-journey-action-id";
}

- (id) initForAnalytics:(SEGAnalytics *)analytics {
    if(self = [super init]) {
        self->analytics = analytics;
    }
    return self;
}

- (void)circumstancesDidOccur:(NSArray<CircumstanceResponse *> *)circumstanceResponses {
    for (CircumstanceResponse *circumstanceResponse in circumstanceResponses) {
        NSString *incidentId = [[NSUUID UUID] UUIDString];
        for(FactualPlace *factualPlace in [circumstanceResponse atPlaces]) {
            [AnalyticsEngineUtil logPlaceEntered:factualPlace incidentId:incidentId forAnalytics:analytics];
        }
        for(FactualPlace *factualPlace in [circumstanceResponse nearPlaces]) {
            [AnalyticsEngineUtil logPlaceNear:factualPlace incidentId:incidentId forAnalytics:analytics];
        }
    }
}

- (void)circumstance:(FactualCircumstance *)circumstance didFailWithError:(NSString *)error {
    NSLog(@"Engine Circumstance Evaluation error: %@", error);
}
@end
