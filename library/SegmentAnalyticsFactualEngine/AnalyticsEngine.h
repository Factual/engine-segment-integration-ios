/*
 * Use of this software is subject to the terms and
 * conditions of the license agreement between you
 * and Factual Inc
 *
 * Copyright © 2017-2018 Factual Inc. All rights reserved.
 */

#import <Analytics/SEGAnalytics.h>
#import "FactualEngine.h"

@interface AnalyticsEngineUtil: NSObject
+ (void) addTrackActionTo:(FactualEngine *)engine forAnalytics:(SEGAnalytics *)analytics;
+ (void) logPlaceEntered:(FactualCircumstance *)circumstance place:(FactualPlace *)place incidentId:(NSString *)incidentId forAnalytics:(SEGAnalytics *)analytics;
+ (void) logPlaceApproached:(FactualCircumstance *)circumstance place:(FactualPlace *)place incidentId:(NSString *)incidentId forAnalytics:(SEGAnalytics *)analytics;

+ (void) trackUserJourneyEvent: (UserJourneyEvent *) userJourneyEvent forAnalytics:(SEGAnalytics *)analytics;
+ (void) logPlaceEntered:(FactualPlace *)factualPlace incidentId:(NSString *)incidentId forAnalytics:(SEGAnalytics *)analytics;
+ (void) logPlaceApproached:(FactualPlace *)factualPlace incidentId:(NSString *)incidentId forAnalytics:(SEGAnalytics *)analytics;
@end

@interface AnalyticsEngineTrackAction: NSObject<FactualActionDelegate>
+ (NSString *) actionId;
- (id) initForAnalytics:(SEGAnalytics *)analytics;
@end

@interface AnalyticsEngineDelegate: NSObject<FactualEngineDelegate>
@property FactualEngine *engine;
+ (instancetype) sharedInstance;
- (id) initForAnalytics:(SEGAnalytics *)analytics;
@end

@interface AnalyticsEngineUserJourneyDelegate: NSObject<UserJourneyDelegate>
- (id) initForAnalytics:(SEGAnalytics *)analytics;
@end
